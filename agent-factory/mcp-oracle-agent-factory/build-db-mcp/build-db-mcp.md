# Build a Database MCP Server

## Introduction

In this lab, you will build a production-grade MCP server that connects to an Oracle Database and exposes SQL tools as MCP-callable functions. This is the pattern used in real-world MCP deployments — the server acts as a bridge between AI agents and your database, allowing natural language queries to be translated into actual SQL operations.

Estimated Time: 20 minutes

### About the Architecture

Your Database MCP Server will:
- Connect to Oracle Database using the `oracledb` Python driver
- Expose tools for running SQL queries, listing users, and checking connectivity
- Use environment variables for secure credential management (no hardcoded passwords)
- Return results as structured JSON that AI agents can parse and present

### Objectives

In this lab, you will:

* Install the `oracledb` Python driver
* Configure database connection using environment variables
* Write a Database MCP server with 4 tools
* Test SQL tool invocations

### Prerequisites

This lab assumes you have:

* SSH access to your Compute Instance
* Python virtual environment with `fastmcp` installed (from Lab 2)
* Access to an Oracle Database (Autonomous DB, 23ai Free, or any Oracle DB)

## Task 1: Install Database Dependencies

1. On your VM, activate your virtual environment and install the Oracle DB driver:

    ```
    <copy>
    source ~/mcpenv/bin/activate
    cd ~/mcp-servers
    pip install oracledb python-dotenv
    </copy>
    ```

## Task 2: Configure Database Connection

1. Create a `.env` file with your database credentials. Use your actual database connection details:

    ```
    <copy>
    cat > .env << 'EOF'
    DB_USER=ADMIN
    DB_PASS=<your-database-password>
    DB_DSN_ALIAS=<your-db-tns-alias>
    TNS_ADMIN=/opt/adb_wallet
    EOF
    </copy>
    ```

    > **Note:** For Autonomous Database users, download your wallet, place it in `/opt/adb_wallet`, and set `DB_DSN_ALIAS` to the TNS alias from `tnsnames.ora`. For 23ai Free on the same VM, use `DB_EZCONNECT=localhost:1521/freepdb1` instead.

## Task 3: Write the Database MCP Server

1. Create a new file called `db_mcp.py`:

    ```
    <copy>
    cat > db_mcp.py << 'PYEOF'
    """
    Oracle Database MCP Server
    Exposes database operations as AI-callable tools via MCP.
    """

    import os
    import json
    import logging
    import datetime
    import decimal
    from typing import Optional, Dict

    from dotenv import load_dotenv
    import oracledb
    from fastmcp import FastMCP

    # ---------- Setup ----------
    load_dotenv()
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")

    # ---------- Database Connection ----------
    class DatabaseOps:
        def __init__(self):
            self.connection = None

        def connect(self) -> bool:
            if self.connection:
                try:
                    self.connection.ping()
                    return True
                except Exception:
                    self.connection = None

            user = os.getenv("DB_USER", "ADMIN")
            pw = os.getenv("DB_PASS")
            cfg = os.getenv("TNS_ADMIN", "/opt/adb_wallet")
            dsn_alias = os.getenv("DB_DSN_ALIAS")
            ez_dsn = os.getenv("DB_EZCONNECT")

            try:
                if dsn_alias:
                    self.connection = oracledb.connect(
                        user=user, password=pw,
                        dsn=dsn_alias, config_dir=cfg
                    )
                elif ez_dsn:
                    self.connection = oracledb.connect(
                        user=user, password=pw, dsn=ez_dsn
                    )
                else:
                    logging.error("No DB_DSN_ALIAS or DB_EZCONNECT set")
                    return False
                return True
            except Exception as e:
                logging.error(f"DB connect failed: {e}")
                self.connection = None
                return False

    _db = DatabaseOps()

    # ---------- JSON Helper ----------
    def _json_safe(v):
        """Convert Oracle types to JSON-serializable values."""
        if isinstance(v, (datetime.datetime, datetime.date)):
            return v.isoformat()
        if isinstance(v, decimal.Decimal):
            return float(v)
        return v

    # ---------- MCP Server ----------
    mcp = FastMCP("OracleDatabaseAgent")

    @mcp.tool()
    def oracle_connect() -> str:
        """Check Oracle DB connectivity and return status."""
        try:
            ok = _db.connect()
            return "Oracle DB is reachable. ✅" if ok else "Oracle DB connection failed. ❌"
        except Exception as e:
            return f"Connection error: {e}"

    @mcp.tool()
    def db_run_sql(query: str, limit: int = 100) -> str:
        """
        Execute a SQL query against the Oracle Database.
        Returns results as JSON with columns and rows.
        Supports SELECT, INSERT, UPDATE, DELETE, and DDL.
        """
        try:
            if not _db.connect():
                return "Oracle connection failed."
            with _db.connection.cursor() as cur:
                cur.execute(query.strip())
                if cur.description:
                    cols = [d[0] for d in cur.description]
                    rows = cur.fetchmany(limit)
                    rows = [[_json_safe(v) for v in r] for r in rows]
                    return json.dumps({"columns": cols, "rows": rows})
                rc = cur.rowcount or 0
                _db.connection.commit()
                return json.dumps({"rowcount": rc})
        except oracledb.Error as e:
            return f"SQL Error: {e}"
        except Exception as e:
            return f"Error: {e}"

    @mcp.tool()
    def db_list_users(pattern: Optional[str] = None) -> str:
        """
        List database users. Optionally filter by LIKE pattern.
        Example: db_list_users('%ADMIN%')
        """
        if not _db.connect():
            return "Oracle connection failed."
        where = "WHERE username LIKE :p" if pattern else ""
        sql = f"""
            SELECT username, account_status,
                   default_tablespace, created
            FROM dba_users {where}
            ORDER BY username
        """
        binds = {"p": pattern} if pattern else {}
        try:
            with _db.connection.cursor() as cur:
                cur.execute(sql, binds)
                cols = [d[0] for d in cur.description]
                rows = [[_json_safe(v) for v in r]
                        for r in cur.fetchmany(200)]
                return json.dumps({"columns": cols, "rows": rows})
        except Exception as e:
            return f"Error: {e}"

    @mcp.tool()
    def db_table_info(table_name: str) -> str:
        """
        Get column information for a specific table.
        Returns column names, data types, and nullable status.
        """
        if not _db.connect():
            return "Oracle connection failed."
        sql = """
            SELECT column_name, data_type,
                   data_length, nullable
            FROM all_tab_columns
            WHERE table_name = :t
            ORDER BY column_id
        """
        try:
            with _db.connection.cursor() as cur:
                cur.execute(sql, {"t": table_name.upper()})
                cols = [d[0] for d in cur.description]
                rows = [[_json_safe(v) for v in r]
                        for r in cur.fetchall()]
                if not rows:
                    return f"Table '{table_name}' not found."
                return json.dumps({"columns": cols, "rows": rows})
        except Exception as e:
            return f"Error: {e}"

    if __name__ == "__main__":
        print("🚀 Starting Oracle Database MCP Server on port 8009...")
        mcp.run(transport="streamable-http", host="0.0.0.0", port=8009)
    PYEOF
    </copy>
    ```

    Let's understand each section of this server in detail.

## Task 4: Understanding the Code — Database MCP Server Anatomy

This server is more complex than the Hello World server. Let's break down every section so there's no confusion:

### Section 1: Imports & Setup

```python
import os, json, logging, datetime, decimal
from typing import Optional, Dict
from dotenv import load_dotenv
import oracledb
from fastmcp import FastMCP

load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
```

| Import | Purpose |
| --- | --- |
| `os` | Read environment variables like `DB_USER`, `DB_PASS` |
| `json` | Convert query results to JSON strings for the AI agent |
| `oracledb` | Official Oracle Database Python driver (lightweight, no Oracle Client needed) |
| `dotenv` / `load_dotenv()` | Loads credentials from the `.env` file so they're not hardcoded |
| `FastMCP` | The MCP framework — same as the Hello World server |

> **Security:** We use `load_dotenv()` to read credentials from a `.env` file. **Never hardcode passwords** in your MCP server code.

### Section 2: The Database Connection Class

```python
class DatabaseOps:
    def __init__(self):
        self.connection = None

    def connect(self) -> bool:
        if self.connection:
            try:
                self.connection.ping()      # Check if existing connection is alive
                return True
            except Exception:
                self.connection = None       # Connection died, reset it
        # ... create new connection ...
```

This class manages the database connection with a **reconnection pattern**:

| Step | What Happens | Why |
| --- | --- | --- |
| Check existing connection | Calls `ping()` on any stored connection | Avoids creating new connections for every tool call |
| Reset on failure | Sets `self.connection = None` if ping fails | Allows fresh reconnection on next call |
| Lazy connect | Only connects when a tool actually needs the DB | Server starts up fast, even if DB is temporarily down |

> **Key Pattern:** This "lazy reconnect" pattern is used in all production MCP servers. It means your server doesn't crash if the database restarts — it silently reconnects on the next tool call.

### Section 3: Connection Configuration via Environment Variables

```python
user = os.getenv("DB_USER", "ADMIN")
pw = os.getenv("DB_PASS")
cfg = os.getenv("TNS_ADMIN", "/opt/adb_wallet")
dsn_alias = os.getenv("DB_DSN_ALIAS")
ez_dsn = os.getenv("DB_EZCONNECT")
```

The server supports **two connection modes** via environment variables:

| Env Variable | When To Use | Example Value |
| --- | --- | --- |
| `DB_DSN_ALIAS` + `TNS_ADMIN` | Autonomous Database (with wallet) | `mydb_high` |
| `DB_EZCONNECT` | Any Oracle DB without wallet | `localhost:1521/freepdb1` |
| `DB_USER` / `DB_PASS` | Always needed | `ADMIN` / `your-password` |

### Section 4: JSON Helper Function

```python
def _json_safe(v):
    if isinstance(v, (datetime.datetime, datetime.date)):
        return v.isoformat()
    if isinstance(v, decimal.Decimal):
        return float(v)
    return v
```

Oracle DB returns Python types like `datetime` and `Decimal` that aren't JSON-serializable. This helper converts them so `json.dumps()` doesn't crash.

| Oracle Type | Converted To | Example |
| --- | --- | --- |
| `datetime.datetime` | ISO string | `"2025-02-27T10:30:00"` |
| `decimal.Decimal` | `float` | `99.99` |
| Everything else | Unchanged | `"ADMIN"`, `42` |

### Section 5: The MCP Server and Tools

```python
mcp = FastMCP("OracleDatabaseAgent")
```

Same pattern as Hello World — create a named server. The name `"OracleDatabaseAgent"` appears in MCP clients.

#### Tool 1: `oracle_connect` — Health Check

```python
@mcp.tool()
def oracle_connect() -> str:
    """Check Oracle DB connectivity and return status."""
```

A simple tool that pings the database and reports if it's alive. The AI agent calls this when the user asks "Is the database working?"

#### Tool 2: `db_run_sql` — The Powerhouse

```python
@mcp.tool()
def db_run_sql(query: str, limit: int = 100) -> str:
    """Execute a SQL query against the Oracle Database."""
```

This is **the most powerful tool** — it runs arbitrary SQL. Key design choices:

| Design Choice | Why |
| --- | --- |
| `limit: int = 100` | Default parameter with a sane limit. Prevents accidentally dumping millions of rows |
| `cur.description` check | Detects if the query returns data (SELECT) vs modifies data (INSERT/UPDATE) |
| Auto-commit for DML | INSERT/UPDATE/DELETE are committed automatically |
| Returns JSON | `{"columns": [...], "rows": [...]}` — structured format the AI can parse |

#### Tool 3: `db_list_users` — Parameterized Query

```python
@mcp.tool()
def db_list_users(pattern: Optional[str] = None) -> str:
    """List database users. Optionally filter by LIKE pattern."""
```

Demonstrates an **optional parameter** — `pattern` defaults to `None`. If provided, it filters with a `LIKE` clause. Uses **bind variables** (`:p`) for SQL injection safety.

#### Tool 4: `db_table_info` — Metadata Query

```python
@mcp.tool()
def db_table_info(table_name: str) -> str:
    """Get column information for a specific table."""
```

Queries Oracle's data dictionary (`all_tab_columns`) to show table structure. Useful when the AI agent needs to understand a table before writing queries.

### Section 6: Start the Server

```python
if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8009)
```

Same pattern as before — listen on all interfaces, port 8009. In the next lab, you'll learn how to run this as a background service that starts on boot.

### Summary: What Makes a Good MCP Tool?

| Guideline | Example |
| --- | --- |
| **Clear docstring** | "Execute a SQL query against the Oracle Database" — tells the AI exactly when to use it |
| **Type-annotated parameters** | `query: str, limit: int = 100` — the AI knows what to send |
| **Sensible defaults** | `limit=100` prevents disasters, `pattern=None` makes filtering optional |
| **Return strings** | All tools return `str` — JSON for structured data, plain text for status |
| **Handle errors gracefully** | `try/except` blocks return error messages instead of crashing |

## Task 5: Run and Test the Database Server

1. Start the Database MCP server:

    ```
    <copy>
    python db_mcp.py
    </copy>
    ```

    You should see:

    ```
    🚀 Starting Oracle Database MCP Server on port 8009...
    ```

    ![DB MCP Server Running](images/db-mcp-server-start.png =50%x*)

2. In a **second SSH session**, test connectivity:

    ```
    <copy>
    curl -s http://localhost:8009/mcp
    </copy>
    ```

3. You can also test the tools with a proper MCP client or by using your AI agent. For a quick smoke test, simply verify the endpoint responds:

    ```
    <copy>
    curl -s http://<your-public-ip>:8009/mcp | head -20
    </copy>
    ```

4. Stop the server with **Ctrl+C** when done testing.

You may now **proceed to the next lab**.

## Learn More

* [python-oracledb Documentation](https://python-oracledb.readthedocs.io)
* [Oracle Autonomous Database Quick Start](https://docs.oracle.com/en/cloud/paas/autonomous-database/)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

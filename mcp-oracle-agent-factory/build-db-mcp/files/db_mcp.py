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

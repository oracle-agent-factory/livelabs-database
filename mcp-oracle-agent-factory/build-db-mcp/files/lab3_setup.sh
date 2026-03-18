#!/bin/bash
# ============================================================
# MCP Workshop — Lab 3 Cumulative Script
# Sets up environment + deploys DB MCP server
# ============================================================
set -e

echo "================================================"
echo "  Lab 3: Database MCP Server Setup"
echo "================================================"

# Ensure environment is set up
source ~/mcpenv/bin/activate 2>/dev/null || {
    echo "Virtual environment not found. Running setup first..."
    python3.11 -m venv ~/mcpenv
    source ~/mcpenv/bin/activate
    pip install --upgrade pip
    pip install fastmcp oracledb python-dotenv
}

mkdir -p ~/mcp-servers
cd ~/mcp-servers

# Check for .env file
if [ ! -f .env ]; then
    echo ""
    echo "⚠️  No .env file found. Creating a template..."
    cat > .env << 'ENVEOF'
DB_USER=ADMIN
DB_PASS=<your-database-password>
DB_DSN_ALIAS=<your-db-tns-alias>
TNS_ADMIN=/opt/adb_wallet
ENVEOF
    echo "  Please edit ~/mcp-servers/.env with your database credentials."
    echo "  Then re-run this script."
    exit 1
fi

# Create db_mcp.py
cat > db_mcp.py << 'PYEOF'
"""Oracle Database MCP Server"""
import os, json, logging, datetime, decimal
from typing import Optional
from dotenv import load_dotenv
import oracledb
from fastmcp import FastMCP

load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")

class DatabaseOps:
    def __init__(self):
        self.connection = None
    def connect(self):
        if self.connection:
            try: self.connection.ping(); return True
            except: self.connection = None
        user, pw = os.getenv("DB_USER","ADMIN"), os.getenv("DB_PASS")
        cfg, dsn = os.getenv("TNS_ADMIN","/opt/adb_wallet"), os.getenv("DB_DSN_ALIAS")
        ez = os.getenv("DB_EZCONNECT")
        try:
            if dsn: self.connection = oracledb.connect(user=user,password=pw,dsn=dsn,config_dir=cfg)
            elif ez: self.connection = oracledb.connect(user=user,password=pw,dsn=ez)
            else: return False
            return True
        except Exception as e: logging.error(f"DB: {e}"); return False

_db = DatabaseOps()
def _js(v):
    if isinstance(v,(datetime.datetime,datetime.date)): return v.isoformat()
    if isinstance(v, decimal.Decimal): return float(v)
    return v

mcp = FastMCP("OracleDatabaseAgent")

@mcp.tool()
def oracle_connect() -> str:
    """Check Oracle DB connectivity."""
    return "Oracle DB reachable ✅" if _db.connect() else "Connection failed ❌"

@mcp.tool()
def db_run_sql(query: str, limit: int = 100) -> str:
    """Execute SQL against Oracle Database. Returns JSON."""
    if not _db.connect(): return "Connection failed."
    try:
        with _db.connection.cursor() as c:
            c.execute(query.strip())
            if c.description:
                cols = [d[0] for d in c.description]
                rows = [[_js(v) for v in r] for r in c.fetchmany(limit)]
                return json.dumps({"columns": cols, "rows": rows})
            _db.connection.commit()
            return json.dumps({"rowcount": c.rowcount or 0})
    except Exception as e: return f"Error: {e}"

@mcp.tool()
def db_list_users(pattern: Optional[str] = None) -> str:
    """List database users. Optional LIKE filter."""
    if not _db.connect(): return "Connection failed."
    w = "WHERE username LIKE :p" if pattern else ""
    try:
        with _db.connection.cursor() as c:
            c.execute(f"SELECT username,account_status,created FROM dba_users {w} ORDER BY username", {"p":pattern} if pattern else {})
            return json.dumps({"columns":[d[0] for d in c.description],"rows":[[_js(v) for v in r] for r in c.fetchmany(200)]})
    except Exception as e: return f"Error: {e}"

@mcp.tool()
def db_table_info(table_name: str) -> str:
    """Get column info for a table."""
    if not _db.connect(): return "Connection failed."
    try:
        with _db.connection.cursor() as c:
            c.execute("SELECT column_name,data_type,data_length,nullable FROM all_tab_columns WHERE table_name=:t ORDER BY column_id",{"t":table_name.upper()})
            rows = [[_js(v) for v in r] for r in c.fetchall()]
            return json.dumps({"columns":[d[0] for d in c.description],"rows":rows}) if rows else f"Table '{table_name}' not found."
    except Exception as e: return f"Error: {e}"

if __name__ == "__main__":
    print("🚀 Starting Oracle Database MCP Server on port 8009...")
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8009)
PYEOF

echo "================================================"
echo "  ✅ db_mcp.py created! Start it with:"
echo "  source ~/mcpenv/bin/activate"
echo "  cd ~/mcp-servers"
echo "  python db_mcp.py"
echo "================================================"

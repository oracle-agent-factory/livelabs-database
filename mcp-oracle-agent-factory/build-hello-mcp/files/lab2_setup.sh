#!/bin/bash
# ============================================================
# MCP Workshop — Lab 2 Cumulative Script
# Sets up environment + deploys Hello World MCP server
# ============================================================
set -e

echo "================================================"
echo "  Lab 2: Hello World MCP Server Setup"
echo "================================================"

# Ensure environment is set up
source ~/mcpenv/bin/activate 2>/dev/null || {
    echo "Virtual environment not found. Running Lab 1 setup first..."
    python3.11 -m venv ~/mcpenv
    source ~/mcpenv/bin/activate
    pip install --upgrade pip
    pip install fastmcp oracledb python-dotenv
}

mkdir -p ~/mcp-servers
cd ~/mcp-servers

# Download hello_mcp.py
cat > hello_mcp.py << 'PYEOF'
from fastmcp import FastMCP
import socket
import datetime

mcp = FastMCP("HelloMCP")

@mcp.tool()
def greet(name: str) -> str:
    """Greet a user by name. Returns a friendly welcome message."""
    return f"Hello, {name}! Welcome to the world of MCP servers. 🚀"

@mcp.tool()
def server_info() -> str:
    """Get basic information about this MCP server host."""
    return (
        f"Hostname: {socket.gethostname()}\n"
        f"Server Time: {datetime.datetime.now().isoformat()}\n"
        f"Python: {__import__('sys').version.split()[0]}\n"
        f"Status: Online ✅"
    )

if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8004)
PYEOF

echo "================================================"
echo "  ✅ hello_mcp.py created! Start it with:"
echo "  source ~/mcpenv/bin/activate"
echo "  cd ~/mcp-servers"
echo "  python hello_mcp.py"
echo "================================================"

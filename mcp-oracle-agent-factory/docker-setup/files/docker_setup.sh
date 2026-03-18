#!/bin/bash
# ============================================================
# MCP Workshop — Docker Setup Script
# Builds the MCP container image, creates the code directory,
# and runs the Hello World MCP server in a container.
# ============================================================
set -e

echo "================================================"
echo "  MCP Server — Docker Setup"
echo "================================================"

# Create project directory
mkdir -p ~/mcp-servers
cd ~/mcp-servers

# Create Dockerfile
cat > Dockerfile << 'DEOF'
FROM python:3.11-slim
LABEL description="MCP Server runtime with FastMCP and Oracle DB driver"
RUN pip install --no-cache-dir fastmcp oracledb python-dotenv
WORKDIR /mcp-servers
CMD ["python", "hello_mcp.py"]
DEOF

# Build the image
echo "[1/3] Building MCP server Docker image..."
docker build -t mcp-server .

# Create hello_mcp.py if it doesn't exist
if [ ! -f hello_mcp.py ]; then
cat > hello_mcp.py << 'PYEOF'
from fastmcp import FastMCP
import socket, datetime

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
        f"Status: Online ✅"
    )

if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8004)
PYEOF
fi

# Open firewall ports
echo "[2/3] Opening firewall ports..."
sudo firewall-cmd --permanent --add-port=8004-8009/tcp 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || true

# Run the container
echo "[3/3] Starting MCP server container..."
docker run -d \
  --name mcp-hello \
  --restart=always \
  -v ~/mcp-servers:/mcp-servers \
  -p 8004:8004 \
  mcp-server

echo "================================================"
echo "  ✅ MCP server running in Docker!"
echo "  View logs: docker logs -f mcp-hello"
echo "  Stop:      docker stop mcp-hello"
echo "  Restart:   docker restart mcp-hello"
echo "================================================"

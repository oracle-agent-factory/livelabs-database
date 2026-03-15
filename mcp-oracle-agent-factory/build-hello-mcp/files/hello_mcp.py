from fastmcp import FastMCP
import socket
import datetime

# Create the MCP server instance
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

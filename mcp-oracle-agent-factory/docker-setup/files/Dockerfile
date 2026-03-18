FROM python:3.11-slim

LABEL maintainer="Lavkesh Singh, Oracle"
LABEL description="MCP Server runtime with FastMCP and Oracle DB driver"

# Install all MCP dependencies
RUN pip install --no-cache-dir \
    fastmcp \
    oracledb \
    python-dotenv

# The MCP server code will be mounted here
WORKDIR /mcp-servers

# Default: run hello_mcp.py (override with docker run command)
CMD ["python", "hello_mcp.py"]

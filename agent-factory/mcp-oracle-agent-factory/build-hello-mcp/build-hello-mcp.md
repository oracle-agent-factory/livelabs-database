# Build Your First MCP Server

## Introduction

In this lab, you will write your first MCP server from scratch using Python's `FastMCP` framework. This will be a simple "Hello World" server with two tools that demonstrate how MCP tools are defined, registered, and invoked. By the end of this lab, you will have a working MCP server running on your VM and responding to requests.

Estimated Time: 15 minutes

### About the MCP Protocol

The **Model Context Protocol (MCP)** is an open standard that allows AI agents to discover and invoke external tools. An MCP server exposes a set of tools — each tool has a name, description, parameters, and a return type. When an AI client connects to your MCP server, it automatically discovers all available tools and can call them on behalf of the user.

The `FastMCP` Python framework makes it trivially easy to define tools using simple decorators.

### Objectives

In this lab, you will:

* Write a minimal MCP server with `@mcp.tool()` decorators
* Understand how tools are defined and discovered
* Run and test the server locally
* Test remote access from your local machine

### Prerequisites

This lab assumes you have:

* SSH access to your Compute Instance (from Lab 2)
* Python virtual environment activated with `fastmcp` installed (from Lab 2)

## Task 1: Write the Hello World MCP Server

1. On your VM, make sure your virtual environment is active:

    ```
    <copy>
    source ~/mcpenv/bin/activate
    </copy>
    ```

2. Create a new directory for your MCP servers and navigate to it:

    ```
    <copy>
    mkdir -p ~/mcp-servers
    cd ~/mcp-servers
    </copy>
    ```

3. Create a new file called `hello_mcp.py`:

    ```
    <copy>
    cat > hello_mcp.py << 'EOF'
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
    EOF
    </copy>
    ```

    Let's understand this code section by section.

## Task 2: Understanding the Code — Anatomy of an MCP Server

Every MCP server has the same fundamental structure. Let's break down each part so you fully understand what's happening:

### Section 1: Imports

```python
from fastmcp import FastMCP
import socket
import datetime
```

| Import | Why We Need It |
| --- | --- |
| `FastMCP` | The core framework that handles MCP protocol, tool registration, HTTP transport, and JSON-RPC |
| `socket` | Used in our `server_info` tool to get the hostname |
| `datetime` | Used to get the current server time |

> **Key Concept:** `FastMCP` is the only MCP-specific dependency. Everything else is standard Python.

### Section 2: Create the Server Instance

```python
mcp = FastMCP("HelloMCP")
```

This creates a **named** MCP server instance. The name `"HelloMCP"` is what MCP clients will see when they connect. Think of it as the server's identity card.

| Parameter | Purpose |
| --- | --- |
| `"HelloMCP"` | The server name — clients display this to users. Use something descriptive like `"DatabaseAgent"` or `"K8sOperations"` |

### Section 3: Define Tools with `@mcp.tool()`

```python
@mcp.tool()
def greet(name: str) -> str:
    """Greet a user by name. Returns a friendly welcome message."""
    return f"Hello, {name}! Welcome to the world of MCP servers. 🚀"
```

This is the **most important concept** — the `@mcp.tool()` decorator. Let's break it down:

| Element | What It Does | Why It Matters |
| --- | --- | --- |
| `@mcp.tool()` | Registers this function as an MCP tool | Without this decorator, the function is invisible to MCP clients |
| `name: str` | Type-annotated parameter | MCP auto-generates the parameter schema from type hints. The client knows to send a string |
| `-> str` | Return type annotation | Tells the client what type of response to expect |
| `"""docstring"""` | Tool description | **This is critical!** The AI agent reads this to decide WHEN to call this tool. Write clear, descriptive docstrings |

> **⚠️ Important:** The **docstring** is what the AI agent uses to understand your tool. If your docstring says "Greet a user by name", the agent will call this tool when a user says "say hello to John". Write your docstrings like instructions for the AI.

### Section 4: The Second Tool

```python
@mcp.tool()
def server_info() -> str:
    """Get basic information about this MCP server host."""
    return (
        f"Hostname: {socket.gethostname()}\n"
        f"Server Time: {datetime.datetime.now().isoformat()}\n"
        f"Python: {__import__('sys').version.split()[0]}\n"
        f"Status: Online ✅"
    )
```

Notice that this tool takes **no parameters** — that's perfectly valid. Not every tool needs input. The agent will call this when a user asks "What server is this?" or "Is the server running?".

### Section 5: Start the Server

```python
if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8004)
```

| Parameter | Value | Purpose |
| --- | --- | --- |
| `transport` | `"streamable-http"` | The communication protocol. HTTP is the standard for remote MCP servers |
| `host` | `"0.0.0.0"` | Listen on ALL network interfaces (not just localhost). Required for remote access |
| `port` | `8004` | The port number. Each MCP server needs its own port |

> **Common Mistake:** If you use `host="localhost"` or `host="127.0.0.1"`, the server will only accept connections from the VM itself — not from remote clients. Always use `"0.0.0.0"` for production servers.

### Quick Reference: MCP Server Template

Every MCP server you build will follow this pattern:

```python
from fastmcp import FastMCP      # 1. Import FastMCP
mcp = FastMCP("ServerName")      # 2. Create server

@mcp.tool()                      # 3. Define tools
def my_tool(param: str) -> str:
    """Description for the AI."""
    return "result"

if __name__ == "__main__":       # 4. Start server
    mcp.run(transport="streamable-http", host="0.0.0.0", port=XXXX)
```

That's it! 4 steps. Everything else is just your business logic inside the tool functions.

## Task 3: Run the Server

1. Start the MCP server:

    ```
    <copy>
    python hello_mcp.py
    </copy>
    ```

    You should see output similar to:

    ```
    INFO     Starting server "HelloMCP" on 0.0.0.0:8004
    ```

    ![Server Running](images/fastmcp-run-terminal.png =50%x*)

    > **Note:** The server will run in the foreground. Keep this terminal open and open a **second SSH session** for testing.

## Task 4: Test the Server Locally

1. In a **second SSH session** to your VM, test the server using `curl`:

    ```
    <copy>
    curl -s http://localhost:8004/mcp | python3 -m json.tool
    </copy>
    ```

    You should see a JSON response listing the available tools (`greet` and `server_info`).

    ![Tool Discovery Response](images/curl-test-tools.png =50%x*)

2. You can also test invoking a tool directly. The exact method depends on the MCP transport, but you can verify the server is alive with:

    ```
    <copy>
    curl -s http://localhost:8004/mcp
    </copy>
    ```

## Task 5: Test Remote Access

1. From your **local machine** (laptop/desktop), test that the server is accessible remotely using your VM's public IP:

    ```
    <copy>
    curl -s http://<your-public-ip>:8004/mcp
    </copy>
    ```

    > **Note:** If this doesn't work, verify your OCI Security List ingress rules (Lab 1, Task 2) and OS firewall (Lab 2, Task 4) are correctly configured.

2. Once you confirm remote access works, stop the server in the first terminal with **Ctrl+C**.

Congratulations! You have built and tested your first MCP server. In the next lab, you will build a more powerful server that connects to an Oracle Database.

You may now **proceed to the next lab**.

## Learn More

* [FastMCP Documentation](https://github.com/jlowin/fastmcp)
* [MCP Protocol Specification](https://modelcontextprotocol.io)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

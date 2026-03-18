# Build & Test Your First MCP Server

## Introduction

In this lab, you will write your first MCP server from scratch using Python's `FastMCP` framework. This will be a simple "Hello World" server with two tools that demonstrate how MCP tools are defined, registered, and invoked. You will then test it end-to-end through **Oracle Agent Factory**.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Write a minimal MCP server with `@mcp.tool()` decorators
* Understand every section of the code in detail
* Run the server on your VM
* Test it through Oracle Agent Factory Playground

### Prerequisites

This lab assumes you have:

* Completed Lab 1 (MCP development environment set up)
* Oracle Agent Factory instance running
* Successful completion of the environment verification script

> **Don't want to type the code?** Download the ready-to-run [hello_mcp.py](files/hello_mcp.py?download=1) file, or download the [cumulative setup script](files/lab2_setup.sh?download=1) that does everything for you.

## Task 1: Write the Hello World MCP Server

1. On your VM, make sure your virtual environment is active:

    ```
    <copy>
    source ~/mcpenv/bin/activate
    cd ~/mcp-servers
    </copy>
    ```

2. Create a new file called `hello_mcp.py`:

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

This creates a **named** MCP server instance. The name `"HelloMCP"` is what Oracle Agent Factory will display when you connect to it.

| Parameter | Purpose |
| --- | --- |
| `"HelloMCP"` | The server name — Agent Factory displays this to users. Use something descriptive like `"DatabaseAgent"` or `"K8sOperations"` |

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
| `@mcp.tool()` | Registers this function as an MCP tool | Without this decorator, the function is invisible to Agent Factory |
| `name: str` | Type-annotated parameter | MCP auto-generates the parameter schema from type hints. Agent Factory knows to send a string |
| `-> str` | Return type annotation | Tells the client what type of response to expect |
| `"""docstring"""` | Tool description | **This is critical!** The AI agent reads this to decide WHEN to call this tool. Write clear, descriptive docstrings |

> **⚠️ Important:** The **docstring** is what the AI agent uses to understand your tool. If your docstring says "Greet a user by name", the agent will call this tool when a user says "say hello to John". Write your docstrings like instructions for the AI.

### Section 4: A No-Parameter Tool

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

This tool takes **no parameters** — that's perfectly valid. Not every tool needs input. The agent will call this when a user asks "What server is this?" or "Is the server running?".

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

> **Common Mistake:** If you use `host="localhost"` or `host="127.0.0.1"`, the server will only accept connections from the VM itself — not from Oracle Agent Factory. Always use `"0.0.0.0"` for production servers.

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

## Task 4: Test in Oracle Agent Factory

Now let's connect your MCP server to Oracle Agent Factory and test it through the Playground.

1. Log in to your **Oracle Agent Factory** instance.

    ![Agent Factory Home](images/agent-factory-home.png =50%x*)

2. Click **Create Flow** to create a new agent flow.

    ![Create Flow](images/create-flow.png =50%x*)

3. In the flow canvas, add an **MCP Server** node. Configure it with your server URL:

    ```
    <copy>
    http://<your-vm-public-ip>:8004/mcp
    </copy>
    ```

    > **Note:** Replace `<your-vm-public-ip>` with the actual public IP of your OCI Compute Instance.

    ![Agent Factory Flow](images/agent-factory-add-mcp-url.png =50%x*)

4. Once connected, Agent Factory will automatically discover the tools exposed by your MCP server. You should see:

    - `greet` — Greet a user by name
    - `server_info` — Get server host information

5. Add a **Chat** node to the flow and connect it to the MCP Server node.

6. Open the **Playground** and test with these queries:

    ```
    <copy>
    Say hello to Lavkesh
    </copy>
    ```

    ```
    <copy>
    What server is this running on?
    </copy>
    ```

    The agent will call the appropriate MCP tools and return the results.

    ![Agent Factory Chat Test](images/agent-factory-chat-with-mcp.png =50%x*)

7. Once you confirm it works, stop the server with **Ctrl+C** in the SSH terminal.

Congratulations! You have built and tested your first MCP server through Oracle Agent Factory. In the next lab, you will build a more powerful server that connects to an Oracle Database.

You may now **proceed to the next lab**.

## Learn More

* [FastMCP Documentation](https://github.com/jlowin/fastmcp)
* [MCP Protocol Specification](https://modelcontextprotocol.io)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, March 2026

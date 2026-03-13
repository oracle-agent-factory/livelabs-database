# Connect to Agent Factory & MCP Clients

## Introduction

In this final lab, you will connect your deployed MCP server to an AI agent client. We will demonstrate two approaches: connecting to **Oracle Agent Factory** (the enterprise solution) and connecting to **open-source MCP clients** like Cline or Claude Desktop. Once connected, your AI agent will be able to discover and invoke your database tools using natural language.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Register your MCP server URL in Oracle Agent Factory
* Test natural language queries against your database through the agent
* Configure an alternative MCP client (Cline/Claude Desktop)
* Verify end-to-end tool invocation

### Prerequisites

This lab assumes you have:

* A running, remotely accessible MCP server (from Lab 5)
* Access to Oracle Agent Factory (or an MCP-compatible client)
* Your VM's public IP address and MCP server port (8009)

## Task 1: Connect to Oracle Agent Factory

1. Log in to your **Oracle Agent Factory** instance. You should see the home screen.

    ![Agent Factory Home](images/agent-factory-home.png =50%x*)

2. Click **Create Flow** to create a new agent flow.

    ![Create Flow](images/create-flow.png =50%x*)

3. In the flow canvas, add an **MCP Server** node. Configure it with your server URL:

    ```
    <copy>
    http://<your-vm-public-ip>:8009/mcp
    </copy>
    ```

    > **Note:** Replace `<your-vm-public-ip>` with the actual public IP of your OCI Compute Instance.

    ![Agent Factory Flow with MCP Server](images/agent-factory-add-mcp-url.png =50%x*)

4. Once connected, Agent Factory will automatically discover the tools exposed by your MCP server. You should see:

    - `oracle_connect` — Check DB connectivity
    - `db_run_sql` — Execute SQL queries
    - `db_list_users` — List database users
    - `db_table_info` — Get table column metadata

5. Add a **Chat** node to the flow and connect it to the MCP Server node.

6. Open the **Playground** and test with these natural language queries:

    ```
    <copy>
    Check if the database is connected
    </copy>
    ```

    ```
    <copy>
    List all database users
    </copy>
    ```

    ```
    <copy>
    Show me the columns in the EMPLOYEES table
    </copy>
    ```

    ```
    <copy>
    Run this query: SELECT table_name FROM user_tables ORDER BY table_name
    </copy>
    ```

    The agent will call the appropriate MCP tools and return the results.

    ![Agent Factory Chat Test](images/agent-factory-chat-with-mcp.png =50%x*)

## Task 2: Connect to Cline (VS Code MCP Client)

For developers who prefer VS Code, you can also connect your MCP server to **Cline** — a popular MCP client extension.

1. Install the **Cline** extension in VS Code.

2. Open the MCP Servers configuration. Navigate to the MCP Servers settings panel.

    ![MCP Server JSON Config](images/mcp-server-json-config.png =50%x*)

3. Add your server to the MCP Servers JSON configuration:

    ```
    <copy>
    {
      "mcpServers": {
        "oracle-db-agent": {
          "url": "http://<your-vm-public-ip>:8009/mcp",
          "disabled": false
        }
      }
    }
    </copy>
    ```

4. Once saved, Cline will discover your tools automatically. You can expand the MCP server to see all available tools.

    ![MCP Tools List](images/mcp-tools-list.png =50%x*)

## Task 3: Connect to Claude Desktop (Optional)

If you have Claude Desktop, you can add your remote MCP server via its configuration file.

1. Edit the Claude Desktop config file:

    - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
    - **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

2. Add your MCP server:

    ```
    <copy>
    {
      "mcpServers": {
        "oracle-db": {
          "url": "http://<your-vm-public-ip>:8009/mcp"
        }
      }
    }
    </copy>
    ```

3. Restart Claude Desktop. Your database tools will appear in the available tools list.

## Task 4: Verify End-to-End

1. Regardless of which client you chose, test these queries to verify everything works:

    | Query | Expected Tool Called |
    | --- | --- |
    | "Is my database online?" | `oracle_connect` |
    | "List database users" | `db_list_users` |
    | "Show me the structure of the DEPARTMENTS table" | `db_table_info` |
    | "SELECT sysdate FROM dual" | `db_run_sql` |

2. Congratulations! 🎉 You have successfully built, deployed, and connected a custom MCP server to an AI agent. Your agent can now query your Oracle Database using natural language.

## What's Next?

Now that you understand the pattern, you can extend your MCP server with additional tools:

* **Email tools** — Send notifications via OCI Email Delivery
* **PDF generation** — Create reports from query results
* **RAG search** — Add vector search using Oracle AI Vector Search
* **Kubernetes tools** — Manage K8s clusters
* **EBS tools** — Query Oracle E-Business Suite via SSH bridge

Each new tool is just a Python function with the `@mcp.tool()` decorator!

## Learn More

* [Model Context Protocol Specification](https://modelcontextprotocol.io)
* [Oracle Agent Factory Documentation](https://docs.oracle.com)
* [Cline VS Code Extension](https://github.com/cline/cline)
* [Claude Desktop MCP Config](https://docs.anthropic.com/claude/docs/model-context-protocol)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

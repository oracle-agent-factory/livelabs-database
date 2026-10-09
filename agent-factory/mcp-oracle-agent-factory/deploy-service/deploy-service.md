# Deploy as a Persistent Service

## Introduction

So far, your MCP servers stop running when you close the terminal or disconnect SSH. In this lab, you will deploy your MCP server as a persistent Linux service using `systemd` — the industry-standard way to run background processes on Linux. This ensures your server starts automatically on boot and restarts if it crashes.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Create a startup wrapper script for your MCP server
* Write a `systemd` service unit file
* Enable and start the service
* Verify the server is running and check logs

### Prerequisites

This lab assumes you have:

* A working Database MCP server (from Lab 4)
* SSH access to your Compute Instance with `sudo` privileges

## Task 1: Create a Startup Script

1. Create a wrapper script that activates the virtual environment and runs the server:

    ```
    <copy>
    cat > ~/mcp-servers/start_db_mcp.sh << 'EOF'
    #!/bin/bash
    echo "MCP Server starting at $(date)" >> /tmp/mcp_server.log
    cd /home/opc/mcp-servers
    export PYTHONUNBUFFERED=1
    source /home/opc/mcpenv/bin/activate
    python -u db_mcp.py 2>&1 | tee -a /tmp/mcp_server.log
    EOF
    chmod +x ~/mcp-servers/start_db_mcp.sh
    </copy>
    ```

## Task 2: Create the systemd Service

1. Create a systemd service unit file:

    ```
    <copy>
    sudo tee /etc/systemd/system/mcp-server.service << 'EOF'
    [Unit]
    Description=Oracle Database MCP Server
    After=network.target

    [Service]
    Type=simple
    User=opc
    WorkingDirectory=/home/opc/mcp-servers
    ExecStart=/home/opc/mcp-servers/start_db_mcp.sh
    Restart=always
    RestartSec=10
    StandardOutput=append:/tmp/mcp_server.log
    StandardError=append:/tmp/mcp_server.log
    EnvironmentFile=/home/opc/mcp-servers/.env

    [Install]
    WantedBy=multi-user.target
    EOF
    </copy>
    ```

    Let's break down the key fields:

    | Field | Purpose |
    | --- | --- |
    | `Restart=always` | Auto-restart if the server crashes |
    | `RestartSec=10` | Wait 10 seconds before restarting |
    | `EnvironmentFile` | Loads your `.env` file with DB credentials |
    | `WantedBy=multi-user.target` | Starts on boot |

## Task 3: Enable and Start the Service

1. Reload systemd to pick up the new service, then enable and start it:

    ```
    <copy>
    sudo systemctl daemon-reload
    sudo systemctl enable mcp-server
    sudo systemctl start mcp-server
    </copy>
    ```

2. Check the service status:

    ```
    <copy>
    sudo systemctl status mcp-server
    </copy>
    ```

    You should see **active (running)** in the output. If you see an error, check the logs.

    ![systemctl status](images/systemctl-status.png =50%x*)

## Task 4: Verify and Monitor

1. Verify the server is responding:

    ```
    <copy>
    curl -s http://localhost:8009/mcp | head -5
    </copy>
    ```

2. Monitor the server logs in real-time:

    ```
    <copy>
    tail -f /tmp/mcp_server.log
    </copy>
    ```

3. Test that the service survives a restart:

    ```
    <copy>
    sudo systemctl restart mcp-server
    sleep 3
    sudo systemctl status mcp-server
    </copy>
    ```

4. Useful service management commands:

    | Command | Purpose |
    | --- | --- |
    | `sudo systemctl stop mcp-server` | Stop the server |
    | `sudo systemctl restart mcp-server` | Restart the server |
    | `sudo systemctl status mcp-server` | Check status |
    | `journalctl -u mcp-server -f` | Follow systemd logs |

## Task 5: (Optional) Run Multiple MCP Servers

You can run additional MCP servers by creating more service files. For example, to also run the Hello World server from Lab 3 on port 8004:

1. Create a second service file:

    ```
    <copy>
    sudo tee /etc/systemd/system/mcp-hello.service << 'EOF'
    [Unit]
    Description=Hello MCP Server
    After=network.target

    [Service]
    Type=simple
    User=opc
    WorkingDirectory=/home/opc/mcp-servers
    ExecStart=/home/opc/mcpenv/bin/python /home/opc/mcp-servers/hello_mcp.py
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now mcp-hello
    </copy>
    ```

    Now you have two MCP servers running persistently on ports 8004 and 8009.

You may now **proceed to the next lab**.

## Learn More

* [systemd Service Documentation](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
* [Managing Services with systemctl](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

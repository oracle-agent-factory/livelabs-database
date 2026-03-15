# (Optional) Containerize Your MCP Server with Docker

## Introduction

In this optional lab, you will containerize your MCP server using Docker. Instead of manually installing Python, venv, and packages on the VM, you will build a Docker image with all prerequisites pre-installed. Your MCP server code lives **outside** the container in a volume-mounted directory — so you can edit your `.py` files normally and just restart the container.

This is the **production-standard** way to deploy MCP servers and is a great alternative to the manual setup in Lab 1 and the systemd deployment in Lab 4.

Estimated Time: 10 minutes

### Why Docker?

| Manual Setup (Lab 1) | Docker Setup (This Lab) |
| --- | --- |
| Install Python, create venv, pip install | `docker build` — one command |
| systemd service for persistence | `--restart=always` — built into Docker |
| Version conflicts possible | Identical environment every time |
| Hard to replicate across VMs | Push image to registry, pull anywhere |

### Objectives

In this lab, you will:

* Install Docker on your OCI Compute Instance
* Build a Docker image with FastMCP and Oracle DB dependencies
* Run your MCP server in a container with volume-mounted code
* Manage the container lifecycle (start, stop, logs, restart)

### Prerequisites

This lab assumes you have:

* An OCI Compute Instance running Oracle Linux
* SSH access with `sudo` privileges
* Completed the Introduction lab

> **Don't want to type everything?** Download the [Dockerfile](files/Dockerfile?download=1) and the [Docker setup script](files/docker_setup.sh?download=1) that does everything automatically.

## Task 1: Install Docker

1. Install Docker on Oracle Linux:

    ```
    <copy>
    sudo dnf install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker opc
    </copy>
    ```

2. Log out and log back in (so the group change takes effect), then verify:

    ```
    <copy>
    docker --version
    </copy>
    ```

    You should see something like `Docker version 24.x` or later.

## Task 2: Create the Dockerfile

The Dockerfile packages all MCP prerequisites into a reusable image. Your actual MCP server code will be **volume-mounted** at runtime — it does NOT live inside the image.

1. Create a project directory and Dockerfile:

    ```
    <copy>
    mkdir -p ~/mcp-servers
    cd ~/mcp-servers

    cat > Dockerfile << 'EOF'
    FROM python:3.11-slim

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
    EOF
    </copy>
    ```

### Understanding the Dockerfile

| Line | What It Does |
| --- | --- |
| `FROM python:3.11-slim` | Starts from a minimal Python 3.11 image (~45MB) |
| `RUN pip install ...` | Pre-installs FastMCP, oracledb, and python-dotenv |
| `WORKDIR /mcp-servers` | Sets the working directory inside the container |
| `CMD ["python", "hello_mcp.py"]` | Default startup command (can be overridden at runtime) |

> **Key Concept:** The Dockerfile only contains **dependencies**. Your actual `.py` files are mounted in via `-v` at runtime. This means you can edit code on the VM and just `docker restart` — no need to rebuild the image.

## Task 3: Build the Docker Image

1. Build the image:

    ```
    <copy>
    docker build -t mcp-server .
    </copy>
    ```

    This takes about 30 seconds. You should see:

    ```
    Successfully built abc123
    Successfully tagged mcp-server:latest
    ```

## Task 4: Run Your MCP Server in a Container

1. First, make sure you have a `hello_mcp.py` in `~/mcp-servers/` (from Lab 2, or download the [hello_mcp.py](../build-hello-mcp/files/hello_mcp.py?download=1) file).

2. Run the Hello World MCP server in a container:

    ```
    <copy>
    docker run -d \
      --name mcp-hello \
      --restart=always \
      -v ~/mcp-servers:/mcp-servers \
      -p 8004:8004 \
      mcp-server
    </copy>
    ```

    Let's break down each flag:

    | Flag | Purpose |
    | --- | --- |
    | `-d` | Run in the background (detached) |
    | `--name mcp-hello` | Give the container a name for easy management |
    | `--restart=always` | Auto-restart on crash or VM reboot (replaces systemd!) |
    | `-v ~/mcp-servers:/mcp-servers` | **Volume mount** — maps your VM's code directory into the container |
    | `-p 8004:8004` | Expose port 8004 from container to VM |

3. Verify it's running:

    ```
    <copy>
    docker ps
    docker logs mcp-hello
    </copy>
    ```

    You should see the server startup message in the logs.

4. Test it from your VM:

    ```
    <copy>
    curl -s http://localhost:8004/mcp | head -5
    </copy>
    ```

## Task 5: Run the Database MCP Server

1. To run the Database MCP server from Lab 3, stop the hello server and start the DB server:

    ```
    <copy>
    docker stop mcp-hello

    docker run -d \
      --name mcp-db \
      --restart=always \
      -v ~/mcp-servers:/mcp-servers \
      --env-file ~/mcp-servers/.env \
      -p 8009:8009 \
      mcp-server \
      python db_mcp.py
    </copy>
    ```

    > **Note:** The `--env-file` flag loads your `.env` credentials into the container. The last argument `python db_mcp.py` overrides the default `CMD` to run the DB server instead.

2. You can run **both servers simultaneously**:

    ```
    <copy>
    docker start mcp-hello

    docker ps
    </copy>
    ```

    Now both servers are running in separate containers on ports 8004 and 8009.

## Task 6: Container Management Cheat Sheet

| Action | Command |
| --- | --- |
| View running containers | `docker ps` |
| View logs (follow) | `docker logs -f mcp-hello` |
| Stop a server | `docker stop mcp-hello` |
| Start a stopped server | `docker start mcp-hello` |
| Restart (after code change) | `docker restart mcp-hello` |
| Remove a container | `docker rm -f mcp-hello` |
| Rebuild image (after Dockerfile change) | `docker build -t mcp-server .` |

### Volume Mount Workflow

The beauty of volume mounting is that your development workflow becomes:

1. Edit `hello_mcp.py` or `db_mcp.py` on the VM (via SSH, VS Code Remote, etc.)
2. Run `docker restart mcp-hello` — the container picks up your changes instantly
3. No rebuild needed!

> **When do you need to rebuild?** Only if you add a new Python package (e.g., `pip install requests`). In that case, add it to the Dockerfile's `RUN pip install` line and run `docker build -t mcp-server .` again.

You have successfully containerized your MCP server! You can now connect it to Oracle Agent Factory the same way as before — the URL is still `http://<your-vm-ip>:8004/mcp` or `http://<your-vm-ip>:8009/mcp`.

## Learn More

* [Docker Documentation](https://docs.docker.com)
* [Oracle Linux Docker Install Guide](https://docs.oracle.com/en/operating-systems/oracle-linux/docker/)
* [Docker Volumes](https://docs.docker.com/storage/volumes/)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, March 2026

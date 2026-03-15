# Set Up Your MCP Development Environment

## Introduction

In this lab, you will connect to your OCI Compute Instance, install Python and the required packages, and prepare the environment for building MCP servers. By the end of this lab, you will have a working Python environment with `FastMCP` installed and firewall ports open for remote MCP access.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Connect to your Compute Instance via SSH
* Install Python 3.11+ and create a virtual environment
* Install `FastMCP` and supporting packages
* Open firewall ports for MCP server traffic
* Run a verification script to confirm everything works

### Prerequisites

This lab assumes you have:

* An OCI Compute Instance running Oracle Linux — [Launch an Instance](https://docs.oracle.com/iaas/Content/Compute/Tasks/launchinginstance.htm)
* SSH key pair configured — [Managing Key Pairs](https://docs.oracle.com/iaas/Content/Compute/Tasks/managingkeypairs.htm)
* OCI Security List with ingress rules for ports 8004-8009 (TCP) — [Security Lists](https://docs.oracle.com/iaas/Content/Network/Concepts/securitylists.htm)
* Successful completion of the Introduction lab

> **Don't want to type everything?** Download the [setup.sh](files/setup.sh?download=1) script and run it — it does everything in this lab automatically.

## Task 1: Connect to Your VM

1. Open a terminal and SSH into your Compute Instance:

    ```
    <copy>
    ssh -i <your-private-key> opc@<your-public-ip>
    </copy>
    ```

    > **Note:** Replace `<your-private-key>` with the path to your SSH private key, and `<your-public-ip>` with your instance's public IP address. For detailed SSH instructions, see [Connecting to an Instance](https://docs.oracle.com/iaas/Content/Compute/Tasks/accessinginstance.htm).

## Task 2: Install Python and Create Virtual Environment

1. Install Python 3.11:

    ```
    <copy>
    sudo dnf install -y python3.11 python3.11-pip python3.11-devel
    </copy>
    ```

2. Create a dedicated virtual environment for your MCP servers:

    ```
    <copy>
    python3.11 -m venv ~/mcpenv
    source ~/mcpenv/bin/activate
    </copy>
    ```

3. Upgrade pip and install the `FastMCP` framework:

    ```
    <copy>
    pip install --upgrade pip
    pip install fastmcp oracledb python-dotenv
    </copy>
    ```

    | Package | Purpose |
    | --- | --- |
    | `fastmcp` | The MCP server framework — handles protocol, tools, HTTP transport |
    | `oracledb` | Oracle Database driver — you'll use this in Lab 3 |
    | `python-dotenv` | Loads `.env` files — keeps passwords out of code |

## Task 3: Open Firewall Ports

1. Open ports 8004-8009 on the OS firewall so your MCP servers can accept remote connections:

    ```
    <copy>
    sudo firewall-cmd --permanent --add-port=8004-8009/tcp
    sudo firewall-cmd --reload
    </copy>
    ```

    > **Note:** You also need matching **OCI Security List ingress rules** for these ports. If you haven't already configured them, see [Adding Security Rules](https://docs.oracle.com/iaas/Content/Network/Concepts/securityrules.htm).

## Task 4: Verify the Environment

1. Create a project directory for your MCP servers:

    ```
    <copy>
    mkdir -p ~/mcp-servers
    cd ~/mcp-servers
    </copy>
    ```

2. Create and run a quick verification script:

    ```
    <copy>
    cat > test_setup.py << 'EOF'
    """Verify MCP development environment is correctly set up."""
    import sys
    import socket

    print("=" * 50)
    print("  MCP Environment Verification")
    print("=" * 50)
    print(f"  Python Version : {sys.version.split()[0]}")
    print(f"  Hostname       : {socket.gethostname()}")
    print(f"  Platform       : {sys.platform}")

    # Check required packages
    checks = []
    for pkg in ["fastmcp", "oracledb", "dotenv"]:
        try:
            __import__(pkg)
            checks.append(f"  ✅ {pkg:15s} installed")
        except ImportError:
            checks.append(f"  ❌ {pkg:15s} MISSING")

    print("-" * 50)
    for c in checks:
        print(c)
    print("=" * 50)

    if all("✅" in c for c in checks):
        print("  🚀 Environment is ready! Proceed to Lab 2.")
    else:
        print("  ⚠️  Some packages are missing. Re-run pip install.")
    print("=" * 50)
    EOF

    python test_setup.py
    </copy>
    ```

    You should see all three packages marked with ✅ and the message **"Environment is ready! Proceed to Lab 2."**

Congratulations! Your MCP development environment is set up. You may now **proceed to the next lab**.

## Learn More

* [OCI Compute Documentation](https://docs.oracle.com/iaas/Content/Compute/home.htm)
* [Python venv Documentation](https://docs.python.org/3/library/venv.html)
* [FastMCP Documentation](https://github.com/jlowin/fastmcp)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, March 2026

# Set Up the Development Environment

## Introduction

In this lab, you will connect to your newly provisioned OCI Compute Instance via SSH, install Python and the required packages, and open the firewall ports for your MCP servers.

Estimated Time: 10 minutes

### Objectives

In this lab, you will:

* Connect to your Compute Instance via SSH
* Install Python 3.11+ and create a virtual environment
* Install the `fastmcp` framework and dependencies
* Open firewall ports on the OS level

### Prerequisites

This lab assumes you have:

* A running OCI Compute Instance (from Lab 1)
* Your SSH private key file
* The public IP address of your instance

## Task 1: Connect via SSH

1. Open a terminal on your local machine (or use OCI Cloud Shell). Connect to your instance using SSH:

    ```
    <copy>
    ssh -i <your-private-key-file> opc@<your-public-ip>
    </copy>
    ```

    ![SSH Login](images/cloudshell-ssh.png =50%x*)

    > **Note:** Replace `<your-private-key-file>` with the path to your private key and `<your-public-ip>` with your instance's public IP address.

2. Verify you are connected. You should see a prompt like:

    ```
    [opc@mcp-server-host ~]$
    ```

## Task 2: Install Python and Create Virtual Environment

1. Check the installed Python version:

    ```
    <copy>
    python3 --version
    </copy>
    ```

    Oracle Linux 8 comes with Python 3.6 by default. We need Python 3.9+. Install it:

    ```
    <copy>
    sudo dnf install -y python39 python39-pip
    </copy>
    ```

2. Create a dedicated virtual environment for your MCP servers:

    ```
    <copy>
    python3.9 -m venv ~/mcpenv
    source ~/mcpenv/bin/activate
    </copy>
    ```

3. Verify the virtual environment is active (you should see `(mcpenv)` in your prompt):

    ```
    <copy>
    which python
    python --version
    </copy>
    ```

## Task 3: Install FastMCP and Dependencies

1. Upgrade pip and install the `fastmcp` framework:

    ```
    <copy>
    pip install --upgrade pip
    pip install fastmcp
    </copy>
    ```

2. Verify the installation:

    ```
    <copy>
    python -c "from fastmcp import FastMCP; print('FastMCP installed successfully!')"
    </copy>
    ```

## Task 4: Open Firewall Ports

1. Open ports 8004-8013 on the OS firewall (the OCI Security List was configured in Lab 1):

    ```
    <copy>
    sudo firewall-cmd --permanent --add-port=8004-8013/tcp
    sudo firewall-cmd --reload
    sudo firewall-cmd --list-ports
    </copy>
    ```

    You should see `8004-8013/tcp` in the output confirming the ports are open.

You may now **proceed to the next lab**.

## Learn More

* [Python Virtual Environments](https://docs.python.org/3/library/venv.html)
* [FastMCP Documentation](https://github.com/jlowin/fastmcp)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

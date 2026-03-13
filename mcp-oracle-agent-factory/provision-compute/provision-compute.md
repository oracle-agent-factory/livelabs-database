# Provision an OCI Compute Instance

## Introduction

In this lab, you will provision an Oracle Cloud Infrastructure (OCI) Compute Instance that will serve as the host for your custom MCP servers. You will also configure the networking security rules to allow inbound traffic on the ports your MCP servers will use.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:

* Create a Compute Instance on OCI with Oracle Linux
* Configure Security List ingress rules for MCP server ports
* Note your instance's public IP address for later use

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account with access to a compartment
* An SSH key pair (public and private key)

## Task 1: Create a Compute Instance

1. Log in to the OCI Console. From the **Navigation Menu** (hamburger icon), navigate to **Compute** > **Instances**.

2. Click **Create Instance**.

    ![Create Instance](images/compute-create.png =50%x*)

3. Enter a **Name** for your instance, for example: `mcp-server-host`.

4. Select the **Image**: Choose **Oracle Linux 8** (or latest available).

    ![Select Oracle Linux](images/compute-oracle-linux.png =50%x*)

5. Select the **Shape**: Choose `VM.Standard.E4.Flex` (or equivalent). Set 1 OCPU and 16 GB memory for a cost-effective setup.

    ![Select Shape](images/compute-shape-select.png =50%x*)

6. Configure **Networking**: Select your VCN and a **public subnet**. Ensure **Assign a public IPv4 address** is checked.

    ![Configure VCN](images/compute-vcn.png =50%x*)

7. Add your **SSH public key**: Paste your public key or upload the `.pub` file.

    ![SSH Key](images/compute-id-rsa-paste.png =50%x*)

8. Click **Create** to launch the instance.

    ![Launch Instance](images/compute-launch.png =50%x*)

9. Wait for the instance status to change from **Provisioning** to **Running**.

    ![Provisioning](images/compute-provisioning.png =50%x*)

10. Once running, note the **Public IP Address** — you will use this throughout the workshop.

    ![Running with IP](images/compute-running-ip.png =50%x*)

## Task 2: Open Ports for MCP Servers

Your MCP servers will listen on ports **8004-8013**. You need to add ingress rules to your VCN's Security List to allow traffic on these ports.

1. From the OCI Console, navigate to **Networking** > **Virtual Cloud Networks**. Click on your VCN.

2. Click on the **Public Subnet**, then click on the **Default Security List**.

    ![Default Security List](images/default-security-list.png =50%x*)

3. Click **Add Ingress Rules**.

    ![Add Ingress Rules](images/add-ingress-rules.png =50%x*)

4. Fill in the following values:

    | Field | Value |
    | --- | --- |
    | Source CIDR | `0.0.0.0/0` |
    | IP Protocol | TCP |
    | Destination Port Range | `8004-8013` |
    | Description | MCP Server Ports |

    ![Enter Ingress Rules](images/enter-ingress-rules.png =50%x*)

5. Click **Add Ingress Rules**. Verify the new rules appear in the list.

    ![New Ingress Rules](images/new-ingress-rules.png =50%x*)

6. Also open the same ports in the **OS firewall** on the instance (you will do this after SSH-ing in the next lab):

    ```
    <copy>
    sudo firewall-cmd --permanent --add-port=8004-8013/tcp
    sudo firewall-cmd --reload
    </copy>
    ```

You may now **proceed to the next lab**.

## Learn More

* [OCI Compute Documentation](https://docs.oracle.com/iaas/Content/Compute/home.htm)
* [OCI Security Lists](https://docs.oracle.com/iaas/Content/Network/Concepts/securitylists.htm)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

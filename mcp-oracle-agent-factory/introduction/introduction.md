# Introduction

## About this Workshop

In this hands-on workshop, you will learn how to build, deploy, and integrate custom **MCP (Model Context Protocol) servers** with **Oracle Agent Factory**. MCP is the open standard that allows AI agents to discover and invoke external tools — turning any API, database, or system into an AI-accessible capability.

You will build two MCP servers from scratch on an OCI Compute VM: a simple "Hello World" server and a production-grade Oracle Database server. You will then deploy them as persistent services and test them end-to-end through the **Oracle Agent Factory Playground**.

By the end of this workshop, you will have fully functional, remotely hosted MCP servers that Oracle Agent Factory can call to query your Oracle Database using natural language.

Estimated Workshop Time: 65 minutes

### Architecture Overview

Your MCP server sits between Oracle Agent Factory and backend systems, acting as a universal tool bridge:

![Architecture Overview](images/architecture-overview.png =50%x*)

### How MCP Works

The MCP protocol follows a simple 3-step flow — Tool Discovery, Tool Invocation, and Response:

![MCP Protocol Flow](images/mcp-protocol-flow.png =50%x*)

### Objectives

In this workshop, you will learn how to:

* Understand the MCP protocol architecture (Agent Factory ↔ MCP Server ↔ Backend)
* Set up a development environment for building MCP servers on OCI
* Build a minimal MCP server using Python's `FastMCP` framework
* Build a database-connected MCP server with Oracle DB tools
* Deploy MCP servers as persistent Linux services using `systemd`
* Test your MCP servers through Oracle Agent Factory Playground

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account (Free Tier or Paid)
* An **OCI Compute Instance** already provisioned and accessible via SSH — [Launch an Instance Guide](https://docs.oracle.com/iaas/Content/Compute/Tasks/launchinginstance.htm)
* An **Oracle Agent Factory** instance running — see your tenancy admin or [Agent Factory Documentation](https://docs.oracle.com)
* Basic familiarity with Python programming
* Basic familiarity with Linux terminal commands
* An SSH key pair — [Managing Key Pairs](https://docs.oracle.com/iaas/Content/Compute/Tasks/managingkeypairs.htm)

> **Note:** If you need help provisioning a Compute Instance, connecting via SSH, or configuring Security Lists, refer to the [OCI Compute documentation](https://docs.oracle.com/iaas/Content/Compute/home.htm).

## Learn More

* [Model Context Protocol Specification](https://modelcontextprotocol.io)
* [FastMCP Python Framework](https://github.com/jlowin/fastmcp)
* [Oracle Agent Factory Documentation](https://docs.oracle.com)
* [OCI Compute Documentation](https://docs.oracle.com/iaas/Content/Compute/home.htm)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, March 2026

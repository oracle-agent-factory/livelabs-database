# Introduction

## About this Workshop

In this hands-on workshop, you will learn how to build, deploy, and integrate custom **MCP (Model Context Protocol) servers** using Python. MCP is the open standard that allows AI agents and LLM clients to discover and invoke external tools — turning any API, database, or system into an AI-accessible capability.

You will start from scratch: provision a cloud VM, write your first MCP server, connect it to an Oracle Database, deploy it as a production service, and finally register it with Oracle Agent Factory (or any MCP-compatible client like Claude Desktop, Cursor, or Cline).

By the end of this workshop, you will have a fully functional, remotely hosted MCP server exposing database tools that any AI agent can call.

Estimated Workshop Time: 90 minutes

### Architecture Overview

Your MCP server sits between AI clients and backend systems, acting as a universal tool bridge:

![Architecture Overview](images/architecture-overview.png =50%x*)

### How MCP Works

The MCP protocol follows a simple 3-step flow — Tool Discovery, Tool Invocation, and Response:

![MCP Protocol Flow](images/mcp-protocol-flow.png =50%x*)

### Objectives

In this workshop, you will learn how to:

* Understand the MCP protocol architecture (Client ↔ Server ↔ Backend)
* Provision and configure an OCI Compute Instance for hosting MCP servers
* Build a minimal MCP server using Python's `FastMCP` framework
* Build a database-connected MCP server with Oracle DB tools
* Deploy MCP servers as persistent Linux services using `systemd`
* Open firewall and security list ports for remote access
* Register and test your MCP server in Oracle Agent Factory

### Prerequisites

This lab assumes you have:

* An Oracle Cloud account (Free Tier or Paid)
* Basic familiarity with Python programming
* Basic familiarity with Linux terminal commands
* SSH key pair for connecting to cloud instances

## Learn More

* [Model Context Protocol Specification](https://modelcontextprotocol.io)
* [FastMCP Python Framework](https://github.com/jlowin/fastmcp)
* [Oracle Agent Factory Documentation](https://docs.oracle.com)
* [OCI Compute Documentation](https://docs.oracle.com/iaas/Content/Compute/home.htm)

## Acknowledgements

* **Author** - Lavkesh Singh, Oracle
* **Last Updated By/Date** - Lavkesh Singh, February 2025

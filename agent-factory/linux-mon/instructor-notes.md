# Linux Monitoring: Instructor Notes

## Introduction

This exercise uses the existing Linux OS Monitoring agent and its six read-only MCP tools. Learners clone the example, inspect its capabilities, ask ordinary operations questions and customize a shift-handover note.

Estimated Time: 15 minutes of learner activity; environment preparation is separate.

### Objectives

- Provide working shared monitoring tools before the session.
- Connect server measurements to application evidence.
- Demonstrate why observation time and coverage matter.

## Preparation

Ensure each learner can see **Linux OS Monitoring** in My Custom Flows, choose the **Linux OS Monitoring** MCP connection and use the workshop model. Existing prepared accounts already have the original Bootcamp flow; verify access after any account or sharing change.

In the AIW HOL instance, **editor@oracleagentfactory.com** owns the **Linux OS Monitoring** MCP connection. Its **Manage access > Groups** settings share it with **aiw26-all-users** at **Can view** access, confirmed in the Editor account on October 21, 2026. Lab users reuse that connection in their cloned flows. Ensure every assigned learner belongs to the group, and keep the learner-account execution check below when preparing a session.

The tool list must contain system overview, resource usage, top processes, filesystem usage, service/network status and recent history. Keep all six explicitly selected. The agent has no shell, restart or other mutation tool.

The monitored environment contains two HTTP applications and three background jobs. Its filesystem tool covers a configured operations filesystem, not every disk. Assigned CPU and memory capacity and the small temporary filesystem are demonstration settings. A healthy server is a valid lab outcome.

Learners replace the copied Agent instructions with the supplied lab file. This keeps operator answers focused on observations and removes internal model references from the original demonstration instructions. The separately validated handover format uses four bullets, without a table.

## Facilitation cues

Open with: "You are nearly out the door when someone asks whether everything is running normally. Which checks stand between you and a responsible yes?"

For a longer opening: "Say you are handing over an operations shift. Your colleague asks whether the server is OK. That sounds like a yes-or-no question, until you remember the CPU chart, the memory reading, the filesystem, two applications and three background jobs. A process can exist without the application doing useful work. You could collect all of that by hand and then write a message. This agent gathers the relevant checks and drafts the handover, so your next shift starts with evidence instead of 'it looked fine when I left.'"

Ask: "If CPU is low, is the application healthy?" Have learners identify an actual application check, then distinguish it from a running process or heartbeat.

On the builder screen, point out that the MCP server is a tool provider. The Agent chooses which tools to call based on the question. Show how a general health request differs from an application, filesystem or trend question.

For the handover, ask the class to retain the time, scope and one next check while shortening the prose. A shorter answer should not become more confident than its evidence.

## Builder walkthrough

| Stop | Functional point | Technical point to demonstrate |
| --- | --- | --- |
| 1. Chat input | Accept the colleague's everyday question. | Its Message output supplies the Agent's Prompt. No tool names are needed in the operator's question. |
| 2. MCP server | Make a bounded set of checks available. | Show the six selected tools. The connection supplies structured evidence; it does not supply a shell or restart operation. |
| 3. Agent | Decide which checks answer the question. | Show the model and instructions: system plus service checks for general health, processes for application questions, history for trends. The tools are available on demand, rather than six mandatory steps for every request. |
| 4. Chat output | Return a useful assessment or handover. | The Agent's Message becomes the response. The final exercise changes the format while preserving times, scope and gaps. |

Before the application check, take a quick vote: "CPU is almost idle. Safe to go home?" Then reveal the application and job checks. If everything is healthy, use that to discuss what was actually checked rather than searching for a fault to keep the story going.

## Timing and checkpoints

| Activity | Minutes |
| --- | ---: |
| Clone and inspect | 3 |
| Review the connection, tools and instructions | 3 |
| Ask two operations questions and inspect evidence | 5 |
| Customize and test the handover | 4 |

Recent history is an optional extension. Do not wait for a new five-minute history window during the core exercise; use available recorded samples and disclose their coverage.

Before class, verify successful tool execution from a learner account. If a tool fails, the correct agent behavior is to report the gap. Do not coach participants to manufacture a fault on the shared machine.

## Production discussion and next steps

Say: "This demo checks one configured machine and a few applications. Production would add authorized fleet selection, retained telemetry, service-specific definitions and organizational thresholds. Any remediation would be a separate workflow."

The demo fixes the machine, application list, ports and operations filesystem in the tools and instructions. To productize it, move that inventory into an authorized configuration source, identify the requested host explicitly, define checks per service, retain time-series evidence and test stale or unavailable telemetry. Keep diagnostic access separate from any later remediation capability. No SQL is required for this agent.

The DBA Incident Detective is a separate captured database case. Do not imply the Linux demonstration machine hosts that database unless the environment has been explicitly configured that way.

## Acknowledgements

- **Author** - Kumar G. Varun, Oracle Database Applied AI
- **Last Updated By/Date** - Kumar G. Varun, October 2026

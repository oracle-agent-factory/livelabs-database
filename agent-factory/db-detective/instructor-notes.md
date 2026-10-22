# DBA Incident Detective: Instructor Notes

## Introduction

This 20-minute exercise uses an actual blocking incident captured on an isolated database clone. Learners configure their own copy of a supplied five-node flow, inspect the evidence, consult the runbook and improve the handover format.

Estimated Time: 20 minutes of learner activity; environment preparation is separate.

### Objectives

- Provide repeatable evidence and an accessible runbook before learners begin.
- Explain why an inactive session can still hold a transaction.
- Demonstrate the distinction between operational records and procedural guidance.

## Preparation

Use the supplied **DBA Incident Detective** example, **DBA Incident Runbook** Knowledge Agent and PDF. The example has five executable nodes and no corrective-action tools. Memory is disabled on the reference flow; check it again on learner copies because cloning can initialize new memory settings.

The database source **DBA Incident Lab** uses a dedicated reader with CREATE SESSION and SELECT on only these two views:

- `HOL_DB_DETECTIVE.INCIDENT_OVERVIEW`
- `HOL_DB_DETECTIVE.INCIDENT_SESSIONS`

The reader has no roles, direct session-catalog access, base-table access or write grants. The Agent's Read only switch is an additional constraint; the database grants establish the underlying boundary.

In the validated installation, Oracle database tools discover connections owned by the current account. Prepare a **DBA Incident Lab** registration for each learner before class. Sharing the flow and Knowledge Agent does not create those registrations. The shared registrations can use the same restricted database reader; no incident data needs to be copied per participant. Never include connection passwords in the learner instructions or the downloadable assets.

Share the runbook source, its Knowledge Agent and the reference flow with the workshop group using view/use access. Confirm a learner can clone the flow, choose its own database registration, call the shared runbook and save its customized response.

The PDF is already ingested for the prepared environment. For another environment, upload [dba-incident-runbook.pdf](files/dba-incident-runbook.pdf) as a file source, wait for **INGESTED**, then create **DBA Incident Runbook** with the workshop model. The text file is the editable source. Do not make ingestion wait time part of the learner's 20 minutes.

## Scenario and expected result

The prepared case has three tagged workload sessions. A batch loader updated a single training row and kept its transaction open while idle. Two requests attempted to update the same row and waited. Session evidence was captured while that relationship existed. The instructor then rolled back the loader, allowed the waiting statements to finish, rolled those transactions back, and closed all workload sessions.

The capture records valid direct and final blocker identifiers, session and instance identity, serial numbers, current wait state, open-transaction indication and capture time. The two waiting requests should point to the same inactive loader. Session identifiers are observations, not values to embed in the agent instructions.

The agent reads stored incident evidence on every investigation. It is not a live monitor. A single captured wait duration is not the full incident duration. The dataset contains no CPU measurements and cannot establish application-wide health.

## Facilitation cues

Open with: "The database is up, but requests are stuck. Who wants to restart it? What would you check first?"

For a longer opening: "Say you are the DBA on call. It is 9:05. Users are saying the application has frozen. The database dashboard is green, someone has already suggested a restart, and three people are asking for an update. You can spend the next ten minutes collecting session information, finding who owns the transaction and looking up the procedure. Or you can ask one question and have an assistant bring the evidence and the procedure together. You still make the decision. This agent helps you arrive at that decision with something better than a hunch."

Before revealing the loader, ask whether an inactive session can hold up active work. Then have someone point to both the blocking identifiers and the open transaction. This keeps the answer grounded in evidence.

On the builder canvas, explain the two tool connections: the database says what was observed; the Knowledge Agent supplies the procedure. Show RB-04 in the PDF and compare it with the recommended checks. The expected citation can be the runbook title and section identifier; the tool does not always propagate a clickable document citation into the custom-flow response.

Close with the handover challenge. Ask which facts the class would retain in five bullets and which statements the evidence cannot support.

## Builder walkthrough

Walk through the canvas in this order. The two tool connections show capabilities available to the Agent; they are not a fixed sequence that runs once from left to right.

| Stop | Functional point | Technical point to demonstrate |
| --- | --- | --- |
| 1. Chat input | The operator asks an ordinary question. | The Message output supplies the Agent's Prompt; the user does not need table names or SQL. |
| 2. Oracle database tools | Establish what happened and who was affected. | The Agent can discover and query two restricted views. Read only is enabled, and database grants enforce the same boundary. There is no SQL script workspace or hardcoded blocker answer. |
| 3. Knowledge Agent | Find the procedure that applies to the finding. | An ingested PDF supplies RB-01 through RB-06. Its Tool output lets the Agent retrieve guidance when needed; the Prompt input remains empty. |
| 4. Agent | Combine observations with a sensible next check. | Show the model selection and instructions for capture time, source scope and runbook references. Memory is disabled, and observations must come from tools. |
| 5. Chat output | Give the DBA an answer they can use. | The Agent's Message becomes the response. The handover exercise changes presentation while retaining evidence and limits. |

Pause before the first answer: "Would you bet on high CPU or a waiting transaction?" After the reveal, ask: "Who voted for the inactive session?" Keep the answer anchored to the observed open transaction and blocking identifiers.

## Timing

| Activity | Minutes |
| --- | ---: |
| Clone and inspect the flow | 3 |
| Rebind the database, runbook and model | 4 |
| Investigate the blocker | 5 |
| Verify the procedure and freshness limitation | 4 |
| Customize and test the handover | 4 |

The target is an estimate, not a timed beginner study. Allow for shared-model and tool latency. If a response appears stalled, reopen the conversation once and check saved history before submitting the same question again. A transport timeout can occur after the answer was saved.

## Production discussion and next steps

Say: "This exercise uses one captured incident so everyone can verify the same relationships. A production version would select authorized databases, collect fresh scoped evidence, preserve instance/session identity, and retrieve the applicable versioned runbook. Any action would need current evidence and a separate authorization workflow."

The demo intentionally fixes the schema, two evidence views and one captured case. It does not embed the solution's session numbers or a canned diagnostic SQL in the Agent. To productize it, add a database and incident selector, a supported evidence collector with collection time and retention, database-specific permissions, versioned runbooks, and tests for incomplete or contradictory evidence. Add performance, patch or audit collectors as separate capabilities with their own coverage definitions; the blocking case does not answer those questions today.

Before a wider session, finish per-learner source registrations, run the exact steps as a learner and check shared-service capacity. For a live extension, use a dedicated training schema with a bounded workload and guaranteed rollback/cleanup. Keep the exercise separate from replicated application tables and primary databases.

## Acknowledgements

- **Author** - Kumar G. Varun, Oracle Database Applied AI
- **Last Updated By/Date** - Kumar G. Varun, October 2026

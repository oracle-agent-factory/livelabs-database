# DBA Incident Detective: Workshop Details

## Short description

Investigate a captured database blocking incident with an assistant that combines database evidence and a runbook.

## Long description

In this 20-minute lab, IT and database practitioners clone a supplied Agent Factory flow, connect a restricted database source and a Knowledge Agent, and ask ordinary support questions. They identify a blocking transaction, compare the recommended checks with a runbook, distinguish captured evidence from current health, and customize an on-call handover. The instructor prepares the database capture, account connections and document ingestion before class.

## Outline

1. Clone and inspect the five-component flow — 3 minutes.
2. Connect the incident evidence, runbook and model — 4 minutes.
3. Identify the blocker and affected requests — 5 minutes.
4. Check the procedure and evidence limits — 4 minutes.
5. Customize and test a short handover — 4 minutes.

## Delivery

- Mode: fastlab; one lab that can be added to the existing Agent Factory workshop.
- Audience: IT, DBA and DevOps practitioners familiar with the introductory builder exercise.
- Preview: serve this folder over HTTP and open `index.html`.
- Existing-workshop integration: add a manifest tutorial whose filename points to `../../db-detective/db-detective.md` from `workshops/aiw2026/`.
- Required preparation: per-account database registrations, shared example and Knowledge Agent, workshop model, captured incident.
- FreeSQL: not used; the exercise teaches tool-based investigation rather than writing SQL.
- Timing: estimate; allow for shared-service latency. No timed beginner study has been performed.

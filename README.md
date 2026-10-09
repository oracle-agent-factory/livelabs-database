# Workshop publishing

This `gh-pages` branch publishes every file under `agent-factory/` and `appgen/` in the `oracle-agent-factory/livelabs-database` fork. It has its own history and must not be merged into a content branch or submitted upstream. `.nojekyll` preserves raw Markdown and the existing LiveLabs URLs.

Keep lab development and upstream PRs on separate content branches. The upstream repository is `oracle-livelabs/database`.

To publish later content changes, create a publishing update branch from `origin/gh-pages` and run:

```bash
git fetch origin
bash publish-labs.sh <content-ref>
git diff --cached --stat
git commit -m "Update published workshops"
git push -u origin HEAD
```

Use a branch named `kvlocal/pages-update-<name>` and replace `<content-ref>` with the branch or commit containing both folders. The script includes all nested labs and assets automatically. It stages only `agent-factory/` and `appgen/` and refuses to run with unsaved changes or on a content branch.

Open publishing update PRs against this fork's `gh-pages` branch. Merging them publishes the site. Content-only PRs go to upstream separately.

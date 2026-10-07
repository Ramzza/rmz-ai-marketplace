# Architecture

This repository is a declarative catalog for GitHub Copilot CLI plugins.

- `.github/plugin/marketplace.json` is the marketplace entry point recognized by Copilot CLI. Its `name` is also the local marketplace key used by the browse command.
- Published plugin sources belong in `plugins/<name>/`; each catalog entry points to its repository-relative directory and includes the plugin metadata required by this marketplace.
- `README.md` documents installation and contribution. `PRD.md` is the source of truth for product requirements.
- `tests/marketplace.bats` checks the manifest, catalog entries, user instructions, and CI triggers. GitHub Actions runs the suite for pushes and pull requests targeting `main`.

The initial catalog is empty so no plugin behavior is assumed or invented.

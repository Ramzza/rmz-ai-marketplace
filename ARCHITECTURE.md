# Architecture

This repository is a GitHub Copilot CLI plugin marketplace with three initial plugins: the migrated RMZ skill collection, a session-end test hook, and TypeScript/JavaScript LSP configuration.

- `.github/plugin/marketplace.json` is the marketplace entry point recognized by Copilot CLI. Its `name` is also the local marketplace key used by the browse command.
- Plugin sources belong in `plugins/<name>/` and use Agent Plugins 1.0 manifests. The `rmz-ai-skills` plugin owns the migrated skill tree under `skills/`; Copilot-specific hooks and LSP settings are under `com.github.copilot/`.
- `test-on-session-end` detects common project test commands and invokes them from a `sessionEnd` hook. `typescript-lsp` configures `typescript-language-server`; users install that server separately.
- `README.md` documents marketplace registration, plugin installation, prerequisites, and contribution. `PRD.md` is the source of truth for product requirements.
- `tests/marketplace.bats` checks manifests, catalog entries, migrated resources, hook behavior, LSP mappings, user instructions, and CI triggers. GitHub Actions runs the suite for pushes and pull requests targeting `main`.

The initial catalog is empty so no plugin behavior is assumed or invented.

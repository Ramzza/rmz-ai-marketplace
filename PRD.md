# Product requirements: rmz-ai-marketplace

## Product

Provide a GitHub Copilot CLI plugin marketplace hosted in this repository. The catalog distributes the skills formerly bundled in `rmz-ai-vm`, a session-end testing hook, and TypeScript/JavaScript language-server configuration.

## Requirements

- **MKT-001 — Discoverable marketplace:** Copilot CLI must find a valid marketplace manifest at `.github/plugin/marketplace.json`. It must identify this marketplace as `rmz-ai-marketplace` and include owner metadata, a non-empty description, a semantic version, and a plugin array.
- **MKT-002 — Installable catalog entries:** Every listed plugin must have a unique kebab-case name, description, semantic version, a repository-relative source directory under `plugins/`, and a matching Agent Plugins 1.0 manifest.
- **MKT-003 — User instructions:** The README must document how to add and browse the marketplace, install its plugins, and satisfy the TypeScript language-server prerequisite.
- **MKT-004 — Continuous verification:** CI must run the marketplace tests for pushes and pull requests targeting `main`.
- **MKT-005 — Migrated skills:** The `rmz-ai-skills` plugin must contain every skill and bundled resource previously distributed from `rmz-ai-vm`, with third-party license notices preserved.
- **MKT-006 — Session-end test hook:** The `test-on-session-end` plugin must run a detected project test command from Copilot CLI's `sessionEnd` hook, report when no supported test command exists, and propagate test failures.
- **MKT-007 — TypeScript LSP:** The `typescript-lsp` plugin must configure `typescript-language-server` for TypeScript and JavaScript file extensions supported by Copilot CLI.

## Verification

| Requirement | Executable test |
| --- | --- |
| MKT-001 | `tests/marketplace.bats`: marketplace manifest metadata and location |
| MKT-002 | `tests/marketplace.bats`: catalog metadata, uniqueness, source directories, and plugin manifests |
| MKT-003 | `tests/marketplace.bats`: marketplace and plugin installation/browse instructions |
| MKT-004 | `tests/marketplace.bats`: workflow triggers and test command; CI runs the Bats suite |
| MKT-005 | `tests/marketplace.bats`: complete migrated skill list, resources, and license notice |
| MKT-006 | `tests/marketplace.bats`: session-end hook structure, test-runner selection, no-test behavior, and failure propagation |
| MKT-007 | `tests/marketplace.bats`: TypeScript/JavaScript LSP command and extension mappings |

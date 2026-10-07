# Product requirements: rmz-ai-marketplace

## Product

Provide a GitHub Copilot CLI plugin marketplace hosted in this repository. The initial catalog is intentionally empty; plugins can be added as they are authored and reviewed.

## Requirements

- **MKT-001 — Discoverable marketplace:** Copilot CLI must find a valid marketplace manifest at `.github/plugin/marketplace.json`. It must identify this marketplace as `rmz-ai-marketplace` and include owner metadata, a non-empty description, a semantic version, and a plugin array.
- **MKT-002 — Installable catalog entries:** Every listed plugin must have a unique kebab-case name, description, semantic version, and a repository-relative source directory under `plugins/` that exists in the repository.
- **MKT-003 — User instructions:** The README must document how to add this marketplace to Copilot CLI, browse it by its manifest name, and disclose that the initial catalog is empty.
- **MKT-004 — Continuous verification:** CI must run the marketplace tests for pushes and pull requests targeting `main`.

## Verification

| Requirement | Executable test |
| --- | --- |
| MKT-001 | `tests/marketplace.bats`: marketplace manifest metadata and location |
| MKT-002 | `tests/marketplace.bats`: catalog entry metadata, uniqueness, and source directories |
| MKT-003 | `tests/marketplace.bats`: marketplace installation, browse, and empty-catalog instructions |
| MKT-004 | `tests/marketplace.bats`: workflow triggers and test command; CI runs the Bats suite |

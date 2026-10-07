# rmz-ai-marketplace

A curated marketplace of plugins for GitHub Copilot CLI.

## Add the marketplace

Register this repository with Copilot CLI:

```shell
copilot plugin marketplace add Ramzza/rmz-ai-marketplace
```

Browse the catalog using the marketplace name from `marketplace.json`:

```shell
copilot plugin marketplace browse rmz-ai-marketplace
```

## Install plugins

Install the migrated RMZ skills:

```shell
copilot plugin install rmz-ai-skills@rmz-ai-marketplace
```

The plugin includes all skills formerly bundled in `rmz-ai-vm`, including the document-conversion, PDFtk, repository-management, and testing workflows.

To run the current project's tests automatically when a Copilot CLI session ends:

```shell
copilot plugin install test-on-session-end@rmz-ai-marketplace
```

The hook detects test commands in Node.js (`npm`, `pnpm`, `yarn`, or `bun`), Rust, Go, Python/pytest, Bats, or a `Makefile`. It reports when no supported test command is found and surfaces test failures after the session.

To enable TypeScript and JavaScript code intelligence:

```shell
copilot plugin install typescript-lsp@rmz-ai-marketplace
npm install -g typescript typescript-language-server
```

Restart Copilot CLI or run `/lsp reload` after installing the language server.

## Contribute a plugin

1. Add an Agent Plugins 1.0 plugin under `plugins/<name>/`, including the root `plugin.json` manifest. Put Copilot-specific hooks and LSP configuration under `com.github.copilot/`.
2. Add an entry to `.github/plugin/marketplace.json` with a unique kebab-case `name`, `description`, semantic `version`, and `source` pointing to the plugin directory (for example, `plugins/my-plugin`).
3. Run the marketplace tests:

   ```shell
   bats tests/marketplace.bats
   ```

See GitHub's guides to [creating plugins](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-creating) and [creating a plugin marketplace](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-marketplace) for supported manifest formats and installation details.

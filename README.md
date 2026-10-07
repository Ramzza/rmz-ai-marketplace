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

No plugins are published yet.

## Contribute a plugin

1. Add an installable Copilot CLI plugin under `plugins/<name>/`, including a plugin manifest as described in the [Copilot CLI plugin documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-creating).
2. Add an entry to `.github/plugin/marketplace.json` with a unique kebab-case `name`, `description`, semantic `version`, and `source` pointing to the plugin directory (for example, `plugins/my-plugin`).
3. Run the marketplace tests:

   ```shell
   bats tests/marketplace.bats
   ```

See GitHub's guide to [creating a plugin marketplace](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-marketplace) for the supported manifest format and installation details.

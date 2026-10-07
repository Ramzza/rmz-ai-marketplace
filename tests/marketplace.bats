setup() {
  ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  MANIFEST="$ROOT/.github/plugin/marketplace.json"
}

@test "MKT-001: marketplace manifest exposes valid Copilot CLI metadata" {
  [ -f "$MANIFEST" ]

  run jq -e '
    (.name | type == "string" and test("^[a-z0-9]+(-[a-z0-9]+)*$") and length <= 64)
    and (.owner.name | type == "string" and length > 0)
    and (.metadata.description | type == "string" and length > 0 and length <= 1024)
    and (.metadata.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    and (.plugins | type == "array")
  ' "$MANIFEST"
  [ "$status" -eq 0 ]
}

@test "MKT-002: plugin entries have unique metadata and existing local sources" {
  [ -f "$MANIFEST" ]

  run jq -e '
    .plugins as $plugins |
    if ($plugins | type) != "array" then false else
      ([$plugins[].name] | length == (unique | length))
      and all($plugins[];
        (.name | type == "string" and test("^[a-z0-9]+(-[a-z0-9]+)*$") and length <= 64)
        and (.description | type == "string" and length > 0 and length <= 1024)
        and (.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
        and (.source | type == "string" and startswith("plugins/") and (split("/") | all(.[]; . != "" and . != "..")))
      )
    end
  ' "$MANIFEST"
  [ "$status" -eq 0 ]

  while IFS= read -r source; do
    source_path="$ROOT/$source"
    [ -d "$source_path" ]
    resolved_source="$(realpath -e "$source_path")"
    [[ "$resolved_source" == "$ROOT/plugins/"* ]]
  done < <(jq -r '.plugins[].source' "$MANIFEST")
}

@test "MKT-003: README explains how to add and browse the marketplace" {
  [ -f "$ROOT/README.md" ]
  grep -Fq 'copilot plugin marketplace add Ramzza/rmz-ai-marketplace' "$ROOT/README.md"
  grep -Fq 'copilot plugin marketplace browse rmz-ai-marketplace' "$ROOT/README.md"
  grep -Fq 'No plugins are published yet.' "$ROOT/README.md"
}

@test "MKT-004: CI validates pushes and pull requests targeting main" {
  WORKFLOW="$ROOT/.github/workflows/validate-marketplace.yml"
  [ -f "$WORKFLOW" ]
  grep -Fq '  push:' "$WORKFLOW"
  grep -Fq '  pull_request:' "$WORKFLOW"
  grep -Fq 'branches: [main]' "$WORKFLOW"
  grep -Fq 'run: bats tests/marketplace.bats' "$WORKFLOW"
}

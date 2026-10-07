#!/usr/bin/env bats

setup() {
  ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  MANIFEST="${ROOT}/.github/plugin/marketplace.json"
  TEST_HOOK="${ROOT}/plugins/test-on-session-end/com.github.copilot/hooks/hooks.json"
  TEST_DIRECTORY="$(mktemp -d)"
  TEST_BIN="${TEST_DIRECTORY}/bin"
  mkdir -p "${TEST_BIN}"
}

teardown() {
  rm -rf -- "${TEST_DIRECTORY}"
}

@test "MKT-001: marketplace manifest exposes valid Copilot CLI metadata" {
  [ -f "${MANIFEST}" ]

  run jq -e '
    (.name | type == "string" and test("^[a-z0-9]+(-[a-z0-9]+)*$") and length <= 64)
    and (.owner.name | type == "string" and length > 0)
    and (.metadata.description | type == "string" and length > 0 and length <= 1024)
    and (.metadata.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
    and (.plugins | type == "array")
  ' "${MANIFEST}"
  [ "${status}" -eq 0 ]
}

@test "MKT-002: catalog entries have unique metadata and valid plugin sources" {
  [ -f "${MANIFEST}" ]

  run jq -e '
    .plugins as $plugins |
    if ($plugins | type) != "array" or ($plugins | length) < 3 then false else
      ([$plugins[].name] | length == (unique | length))
      and all($plugins[];
        (.name | type == "string" and test("^[a-z0-9]+(-[a-z0-9]+)*$") and length <= 64)
        and (.description | type == "string" and length > 0 and length <= 1024)
        and (.version | type == "string" and test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))
        and (.source | type == "string" and startswith("plugins/") and (split("/") | all(.[]; . != "" and . != "..")))
      )
    end
  ' "${MANIFEST}"
  [ "${status}" -eq 0 ]

  while IFS=$'\t' read -r name source version description; do
    source_path="${ROOT}/${source}"
    [ -d "${source_path}" ]
    resolved_source="$(realpath -e "${source_path}")"
    [[ "${resolved_source}" == "${ROOT}/plugins/"* ]]
    plugin_manifest="${source_path}/plugin.json"
    [ -f "${plugin_manifest}" ]
    run jq -e \
      --arg name "${name}" \
      --arg version "${version}" \
      --arg description "${description}" '
      .["$schema"] == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
      and .name == $name
      and .version == $version
      and .description == $description
    ' "${plugin_manifest}"
    [ "${status}" -eq 0 ]
  done < <(jq -r '.plugins[] | [.name, .source, .version, .description] | @tsv' "${MANIFEST}")
}

@test "MKT-003: README documents adding, browsing, and installing plugins" {
  [ -f "${ROOT}/README.md" ]
  grep -Fq 'copilot plugin marketplace add Ramzza/rmz-ai-marketplace' "${ROOT}/README.md"
  grep -Fq 'copilot plugin marketplace browse rmz-ai-marketplace' "${ROOT}/README.md"
  grep -Fq 'copilot plugin install rmz-ai-skills@rmz-ai-marketplace' "${ROOT}/README.md"
  grep -Fq 'copilot plugin install test-on-session-end@rmz-ai-marketplace' "${ROOT}/README.md"
  grep -Fq 'copilot plugin install typescript-lsp@rmz-ai-marketplace' "${ROOT}/README.md"
  grep -Fq 'npm install -g typescript typescript-language-server' "${ROOT}/README.md"
}

@test "MKT-004: CI validates pushes and pull requests targeting main" {
  WORKFLOW="${ROOT}/.github/workflows/validate-marketplace.yml"
  [ -f "${WORKFLOW}" ]
  grep -Fq '  push:' "${WORKFLOW}"
  grep -Fq '  pull_request:' "${WORKFLOW}"
  grep -Fq 'branches: [main]' "${WORKFLOW}"
  grep -Fq 'run: bats tests/marketplace.bats' "${WORKFLOW}"
}

@test "MKT-005: skills plugin contains all migrated skills, resources, and notices" {
  SKILLS_DIRECTORY="${ROOT}/plugins/rmz-ai-skills/skills"
  [ -d "${SKILLS_DIRECTORY}" ]
  [ -f "${ROOT}/plugins/rmz-ai-skills/THIRD-PARTY-LICENSES.md" ]

  expected_skill_names="$(printf '%s\n' \
    code-review \
    convert-excel-to-md \
    convert-pdf-to-md \
    convert-word-to-md \
    md-to-docx \
    pdftk-server \
    playwright-explore-website \
    rmz-clean-workspace \
    rmz-conversation-skill-curator \
    rmz-create-agentsmd \
    rmz-create-repo \
    rmz-create-repository \
    rmz-create-skill \
    rmz-test \
    rmz-test-shell \
    rmz-test-typescript \
    rmz-update-agentsmd \
    rmz-update-instructions \
    rmz-update-skill | sort)"
  actual_skill_names="$(find "${SKILLS_DIRECTORY}" -mindepth 2 -maxdepth 2 \
    -name SKILL.md -printf '%h\n' | while IFS= read -r skill_path; do
      basename "${skill_path}"
    done | sort)"
  [ "${actual_skill_names}" = "${expected_skill_names}" ]
  grep -Fqx -- '- `playwright-explore-website`' \
    "${ROOT}/plugins/rmz-ai-skills/THIRD-PARTY-LICENSES.md"

  for resource in \
    convert-excel-to-md/references/setup.md \
    convert-excel-to-md/scripts/convert_excel_to_md.py \
    convert-excel-to-md/scripts/requirements.txt \
    convert-pdf-to-md/references/setup.md \
    convert-pdf-to-md/scripts/convert_pdf_to_md.py \
    convert-pdf-to-md/scripts/requirements.txt \
    convert-word-to-md/references/setup.md \
    convert-word-to-md/scripts/convert_word_to_md.py \
    convert-word-to-md/scripts/requirements.txt \
    md-to-docx/scripts/md-to-docx.mjs \
    md-to-docx/scripts/package.json \
    pdftk-server/references/download.md \
    pdftk-server/references/pdftk-cli-examples.md \
    pdftk-server/references/pdftk-man-page.md \
    pdftk-server/references/pdftk-server-license.md \
    pdftk-server/references/third-party-materials.md; do
    [ -f "${SKILLS_DIRECTORY}/${resource}" ]
  done

  for skill_directory in "${SKILLS_DIRECTORY}"/*; do
    skill_name="${skill_directory##*/}"
    [ -f "${skill_directory}/SKILL.md" ]
    grep -Fqx "name: ${skill_name}" "${skill_directory}/SKILL.md"
  done

  playwright_skill="${SKILLS_DIRECTORY}/playwright-explore-website/SKILL.md"
  grep -Fqx '# Website Exploration for Testing' "${playwright_skill}"
  grep -Fqx \
    '6. Propose and generate test cases based on the exploration.' \
    "${playwright_skill}"
}

create_runner_stub() {
  local command_name="$1"

  if [[ "${command_name}" == "node" ]]; then
    cat >"${TEST_BIN}/${command_name}" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >>"${TEST_RUNNER_LOG:?}"
printf '%s\n' "${TEST_NODE_HAS_TEST:-true}"
true
EOF
  else
    cat >"${TEST_BIN}/${command_name}" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >>"${TEST_RUNNER_LOG:?}"
[ "${TEST_RUNNER_STATUS:-0}" -eq 0 ]
EOF
  fi
  chmod +x "${TEST_BIN}/${command_name}"
}

run_session_end_hook() {
  local project_directory="$1"
  local runner_status="${2:-0}"
  local node_has_test="${3:-true}"

  (
    cd "${project_directory}"
    env \
      PATH="${TEST_BIN}:${PATH}" \
      TEST_RUNNER_LOG="${TEST_DIRECTORY}/runner.log" \
      TEST_RUNNER_STATUS="${runner_status}" \
      TEST_NODE_HAS_TEST="${node_has_test}" \
      bash -c "${SESSION_END_COMMAND}"
  )
}

@test "MKT-006: session-end hook runs standard test commands and propagates failures" {
  [ -f "${TEST_HOOK}" ]
  run jq -e '
    .version == 1
    and (.hooks.sessionEnd | type == "array" and length == 1)
    and (.hooks.sessionEnd[0].type == "command")
    and (.hooks.sessionEnd[0].bash | type == "string" and length > 0)
    and (.hooks.sessionEnd[0].cwd == ".")
    and (.hooks.sessionEnd[0].timeoutSec >= 30)
  ' "${TEST_HOOK}"
  [ "${status}" -eq 0 ]
  SESSION_END_COMMAND="$(jq -r '.hooks.sessionEnd[0].bash' "${TEST_HOOK}")"

  create_runner_stub node
  create_runner_stub npm
  create_runner_stub cargo
  create_runner_stub go
  create_runner_stub python
  create_runner_stub bats
  create_runner_stub make

  project_directory="${TEST_DIRECTORY}/node-project"
  mkdir -p "${project_directory}"
  printf '%s\n' '{"scripts":{"test":"node test.js"}}' >"${project_directory}/package.json"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'npm test' "${TEST_DIRECTORY}/runner.log"

  project_directory="${TEST_DIRECTORY}/rust-project"
  mkdir -p "${project_directory}"
  touch "${project_directory}/Cargo.toml"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'cargo test' "${TEST_DIRECTORY}/runner.log"

  project_directory="${TEST_DIRECTORY}/go-project"
  mkdir -p "${project_directory}"
  touch "${project_directory}/go.mod"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'go test ./...' "${TEST_DIRECTORY}/runner.log"

  project_directory="${TEST_DIRECTORY}/python-project"
  mkdir -p "${project_directory}"
  touch "${project_directory}/pyproject.toml"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'python -m pytest' "${TEST_DIRECTORY}/runner.log"

  project_directory="${TEST_DIRECTORY}/bats-project"
  mkdir -p "${project_directory}/tests"
  touch "${project_directory}/tests/example.bats"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'bats tests' "${TEST_DIRECTORY}/runner.log"

  project_directory="${TEST_DIRECTORY}/make-project"
  mkdir -p "${project_directory}"
  printf '%s\n' 'test:' >"${project_directory}/Makefile"
  run run_session_end_hook "${project_directory}"
  [ "${status}" -eq 0 ]
  grep -Fqx 'make test' "${TEST_DIRECTORY}/runner.log"

  run run_session_end_hook "${TEST_DIRECTORY}/node-project" 1
  [ "${status}" -ne 0 ]
}

@test "MKT-006: session-end hook honors Node.js package-manager lockfiles" {
  [ -f "${TEST_HOOK}" ]
  SESSION_END_COMMAND="$(jq -r '.hooks.sessionEnd[0].bash' "${TEST_HOOK}")"
  create_runner_stub node
  create_runner_stub pnpm
  create_runner_stub yarn
  create_runner_stub bun

  for package_manager in pnpm yarn bun; do
    project_directory="${TEST_DIRECTORY}/${package_manager}-project"
    mkdir -p "${project_directory}"
    printf '%s\n' '{"scripts":{"test":"node test.js"}}' \
      >"${project_directory}/package.json"
    case "${package_manager}" in
      pnpm) touch "${project_directory}/pnpm-lock.yaml" ;;
      yarn) touch "${project_directory}/yarn.lock" ;;
      bun) touch "${project_directory}/bun.lock" ;;
    esac
    : >"${TEST_DIRECTORY}/runner.log"

    run run_session_end_hook "${project_directory}"

    [ "${status}" -eq 0 ]
    grep -Fqx "${package_manager} test" "${TEST_DIRECTORY}/runner.log"
  done
}

@test "MKT-006: session-end hook reports when no supported tests exist" {
  [ -f "${TEST_HOOK}" ]
  SESSION_END_COMMAND="$(jq -r '.hooks.sessionEnd[0].bash' "${TEST_HOOK}")"
  project_directory="${TEST_DIRECTORY}/empty-project"
  mkdir -p "${project_directory}"
  printf '%s\n' '{"scripts":{}}' >"${project_directory}/package.json"
  create_runner_stub node

  run run_session_end_hook "${project_directory}" 0 false

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"No supported test command found"* ]]
}

@test "MKT-007: TypeScript LSP config covers TypeScript and JavaScript" {
  LSP_CONFIG="${ROOT}/plugins/typescript-lsp/com.github.copilot/lsp.json"
  [ -f "${LSP_CONFIG}" ]
  run jq -e '
    .lspServers.typescript.command == "typescript-language-server"
    and .lspServers.typescript.args == ["--stdio"]
    and .lspServers.typescript.fileExtensions == {
      ".ts": "typescript",
      ".tsx": "typescriptreact",
      ".js": "javascript",
      ".jsx": "javascriptreact",
      ".mjs": "javascript",
      ".cjs": "javascript",
      ".mts": "typescript",
      ".cts": "typescript"
    }
  ' "${LSP_CONFIG}"
  [ "${status}" -eq 0 ]
}

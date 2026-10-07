---
name: rmz-update-skill
description: Update an existing GitHub Copilot CLI skill in the rmz-ai-skills plugin; use when a requested skill already exists.
---

# Update a repository Copilot skill

Use this skill only to update an existing skill in the `rmz-ai-skills` plugin in `rmz-ai-marketplace`. Before making changes, check whether `plugins/rmz-ai-skills/skills/<skill-name>/SKILL.md` exists. If it does not exist, do not create it here; hand off to the `rmz-create-skill` skill. If it exists, update it there.

## Source of truth and location

- The canonical copy of every marketplace skill is `plugins/rmz-ai-skills/skills/<skill-name>/SKILL.md`. Update that copy; do not edit only a project-local or installed copy.
- Keep the skill directory and its `name` frontmatter value matching, concise, lowercase, and kebab-case.
- Preserve valid YAML frontmatter with a specific `description` that says what the skill does and when Copilot should use it.
- Keep supporting scripts and references inside the skill's directory, and update them only when needed for the requested change.

## Updating a useful skill

1. Read the existing skill and any directly relevant supporting files before editing.
2. Preserve the skill's intended trigger and scope unless the request explicitly changes them.
3. Make the smallest complete change that addresses the request, keeping instructions actionable and in the order they should be done.
4. Prefer repository conventions and existing tools. Do not duplicate instructions already provided by Copilot or the VM.
5. Do not add secrets, machine-specific credentials, or generated state.

## Validation

- Check that the directory name still matches its frontmatter `name`, that the YAML frontmatter parses, and that paths and commands in the instructions are accurate.
- The plugin source is canonical; after release, users can refresh it with `copilot plugin update rmz-ai-skills`.
- Update the README and marketplace tests if the plugin's storage convention changes.

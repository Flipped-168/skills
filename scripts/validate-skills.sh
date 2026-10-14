#!/usr/bin/env bash
# Spec validation for every published skill, using skills-ref
# (the Agent Skills reference validator). Same command CI runs.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v uvx >/dev/null 2>&1; then
  echo "validate-skills: uvx not found; install uv (https://docs.astral.sh/uv/) to run spec validation" >&2
  exit 1
fi

# Skill paths never hold spaces, so the list word-splits safely.
skill_dirs=$(node scripts/lib/skills.mjs)
for d in $skill_dirs; do
  # uv fetches the validator with its own git commands, and inside a commit hook
  # these variables point at this repo, so uv's git would act on it instead.
  env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE -u GIT_PREFIX -u GIT_COMMON_DIR \
    -u GIT_OBJECT_DIRECTORY -u GIT_ALTERNATE_OBJECT_DIRECTORIES \
    uvx --from "git+https://github.com/agentskills/agentskills.git#subdirectory=skills-ref" skills-ref validate "$d"
done

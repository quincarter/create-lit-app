#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf -- "$WORK"' EXIT
cd "$WORK"

for template in full blank custom; do
  bash "$ROOT/create-app-shell.sh" "test-$template" --template="$template" --pm=npm --no-git --no-install -y > /dev/null
  (
    cd "test-$template"
    for file in CLAUDE.md GEMINI.md; do
      test -L "$file"
      test "$(readlink "$file")" = AGENTS.md
      cmp AGENTS.md "$file"
    done
    for assistant in .claude .windsurf; do
      for directory in skills agents; do
        test -L "$assistant/$directory"
        test "$(readlink "$assistant/$directory")" = "../.agents/$directory"
        test -f "$assistant/$directory/.gitkeep"
        echo shared > "$assistant/$directory/probe"
        test "$(cat ".agents/$directory/probe")" = shared
      done
    done
    for agent in lit-expert typescript-expert code-reviewer ui-designer test-expert; do
      definition=".agents/agents/$agent.md"
      test -s "$definition"
      test "$(head -n 1 "$definition")" = ---
      grep -qx "name: $agent" "$definition"
      grep -q '^description: .' "$definition"
      test "$(grep -cx -- '---' "$definition")" -eq 2
      grep -q 'AGENTS.md' "$definition"
      grep -q "$agent" AGENTS.md
      for assistant in .claude .windsurf; do
        cmp "$definition" "$assistant/agents/$agent.md"
      done
      echo synchronized >> ".claude/agents/$agent.md"
      cmp "$definition" ".windsurf/agents/$agent.md"
    done
    # Skills: create-component everywhere; create-view needs the router and
    # create-signal-store needs signals, which the blank template turns off.
    expected="create-component"
    absent=""
    if [ "$template" = blank ]; then
      absent="create-view create-signal-store"
    else
      expected="$expected create-view create-signal-store"
    fi
    for skill in $expected; do
      definition=".agents/skills/$skill/SKILL.md"
      test -s "$definition"
      test "$(head -n 1 "$definition")" = ---
      grep -qx "name: $skill" "$definition"
      grep -q '^description: .' "$definition"
      grep -q -- "- $skill:" AGENTS.md
      for assistant in .claude .windsurf; do
        cmp "$definition" "$assistant/skills/$skill/SKILL.md"
      done
    done
    for skill in $absent; do
      test ! -e ".agents/skills/$skill"
      if grep -q -- "$skill" AGENTS.md; then
        echo "AGENTS.md mentions $skill, which test-$template does not generate" >&2
        exit 1
      fi
    done
    echo synchronized >> AGENTS.md
    cmp AGENTS.md CLAUDE.md
    cmp AGENTS.md GEMINI.md
  )
done
echo "Agent scaffolding, shared sub-agents and skills passed for full, blank, and custom templates."

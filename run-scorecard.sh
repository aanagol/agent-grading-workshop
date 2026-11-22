#!/usr/bin/env bash
# Loops samples/questions.md through the support-drafter and support-grader
# subagents and writes a combined scorecard to samples/scorecard.md.
#
# Run from a terminal (not from inside a Claude Code session) with the
# `claude` CLI on PATH, from this directory, so the subagents in
# .claude/agents/ are registered:
#
#   cd support-agent-workshop
#   ./run-scorecard.sh

set -uo pipefail
cd "$(dirname "$0")"

QUESTIONS_FILE="samples/questions.md"
OUT_FILE="samples/scorecard.md"

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH" >&2
  exit 1
fi

# Read all questions into memory up front (not mapfile — macOS ships bash 3.2,
# which lacks it). Looping with `while read ... done < file` while also calling
# `claude` inside the loop lets claude's own stdin steal the rest of the file
# (both share fd 0), so the loop would silently stop after one iteration.
lines=()
while IFS= read -r line || [[ -n "$line" ]]; do
  lines+=("$line")
done < "$QUESTIONS_FILE"

{
  echo "# Support Agent Scorecard"
  echo ""
  echo "Generated $(date)"
  echo ""
} > "$OUT_FILE"

i=0
for question in "${lines[@]}"; do
  [[ -z "$question" || "$question" == \#* ]] && continue
  i=$((i + 1))
  echo "[$i] $question"

  reply=$(claude -p "Use the support-drafter subagent to draft a reply to this customer question. Output only the reply text, nothing else. Question: $question" </dev/null)

  grade=$(claude -p "Use the support-grader subagent to grade this support reply against the rubric. Output only the scorecard table and the overall verdict, nothing else.

Customer question: $question

Reply to grade: $reply" </dev/null)

  {
    echo "## Question $i"
    echo ""
    echo "**Customer:** $question"
    echo ""
    echo "**Reply:**"
    echo ""
    echo "$reply"
    echo ""
    echo "**Grade:**"
    echo ""
    echo "$grade"
    echo ""
    echo "---"
    echo ""
  } >> "$OUT_FILE"
done

echo "Done — $i questions scored. See $OUT_FILE"

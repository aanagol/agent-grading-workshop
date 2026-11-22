#!/usr/bin/env bash
# Grades your own real question + answer pairs against support-grader,
# skipping support-drafter entirely -- no new replies are generated,
# it only scores what's already in samples/qa-pairs.md.
#
# Before running: put your real facts in product-context.md and your
# real Q&A pairs in samples/qa-pairs.md. support-grader checks "Accurate"
# and "No invented policy" against product-context.md, so an empty or
# fictional context file makes every score meaningless.
#
# Run from a plain terminal (not from inside a Claude Code session):
#   cd support-agent-workshop
#   ./grade-existing.sh

set -uo pipefail
cd "$(dirname "$0")"

QA_FILE="samples/qa-pairs.md"
OUT_FILE="samples/scorecard-existing.md"

if ! command -v claude >/dev/null 2>&1; then
  echo "error: 'claude' CLI not found on PATH" >&2
  exit 1
fi

{
  echo "# Existing-Answer Scorecard"
  echo ""
  echo "Generated $(date)"
  echo ""
} > "$OUT_FILE"

i=0
while IFS= read -r -d '' block; do
  [[ -z "${block//[$'\n\t ']/}" ]] && continue

  question=$(printf '%s' "$block" | awk '/^Q:/{sub(/^Q: */,""); print; exit}')
  answer=$(printf '%s' "$block" | awk 'BEGIN{f=0} /^A:/{f=1; sub(/^A: */,""); if(length($0)>0) print; next} f{print}')

  [[ -z "$question" || -z "$answer" ]] && continue
  i=$((i + 1))
  echo "[$i] $question"

  grade=$(claude -p "Use the support-grader subagent to grade this support reply against the rubric. Output only the scorecard table and the overall verdict, nothing else.

Customer question: $question

Reply to grade: $answer" </dev/null)

  {
    echo "## Question $i"
    echo ""
    echo "**Customer:** $question"
    echo ""
    echo "**Reply (as actually sent):**"
    echo ""
    echo "$answer"
    echo ""
    echo "**Grade:**"
    echo ""
    echo "$grade"
    echo ""
    echo "---"
    echo ""
  } >> "$OUT_FILE"
done < <(awk -v RS='\n---\n' '{printf "%s\0", $0}' "$QA_FILE")

echo "Done — $i pairs graded. See $OUT_FILE"

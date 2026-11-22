# agent-grading-workshop
Writing and grading AI agents: a small LLM-as-a-judge exercise

A hands-on exercise built in Claude Code: write a rubric first, build a drafting agent and a grading agent, then check whether the grader can be trusted. I taught the method to the Neythri community. The scenario (Northwind Cloud, a cloud-storage support desk) is fictional.

What is here
File	What it is
Writing_eval_agent.pdf	The participant handout
rubric.md	Five criteria, scored 1 to 5; any score below 3 counts as a fail
product-context.md	The fact file both agents read; anything not listed is not a known fact
agents/	The drafter and grader agent files (copy them to .claude/agents/ to use)
run-scorecard.sh	Drafts and grades each question in samples/questions.md and writes samples/scorecard.md
grade-existing.sh	Grades question and answer pairs you supply, without drafting
scorecard.md	Output of one run, generated July 17, 2026
The run in scorecard.md

Ten test questions. The grader passed 8 replies and failed 2:

Question 2: the reply stated a detail about uploads after a downgrade that is not in the fact file.
Question 7: the reply's opening sentence contradicted the next one.
Limitations
Ten questions, one run.
The drafter and the grader are both Claude.
The pass or fail verdicts come from the grader. They have not been validated against human labels at scale.
<!-- TO COMPLETE BEFORE PUBLISHING IF YOU WANT IT HERE: add a section titled "Review of the eight passes" with your own reading of each pass against product-context.md (which claims were supported, which were not). -->
Running it

You need the claude command-line tool. Run the scripts from a plain terminal, not from inside a Claude Code session, in the project folder where the agent files are in .claude/agents/.

./run-scorecard.sh
./grade-existing.sh

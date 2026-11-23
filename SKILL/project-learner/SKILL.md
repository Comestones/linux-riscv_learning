---
name: project-learner
description: Learn and master any local codebase through source-backed explanations, a dynamically generated curriculum, guided questions, code walkthroughs, and optional progress tracking. Use when the user asks to learn, understand, study, onboard to, or build a mental model of a project, repository, architecture, subsystem, or unfamiliar codebase.
---

# Project Learner

Teach the active project from its actual files. Never assume a language, framework, architecture, or fixed topic list.

## 1. Resolve the target

1. Use an explicit path or project alias from the user or `AGENTS.md`.
2. Otherwise use the active workspace repository.
3. If multiple plausible repositories exist and the choice changes the lesson, ask one concise question.
4. State the resolved project once before beginning.

## 2. Discover before teaching

Inspect only enough material to build a reliable map:

- repository guidance such as `AGENTS.md`;
- README, architecture, specification, and operational docs;
- dependency and build manifests;
- source tree, entry points, configuration, migrations, and tests;
- recent implementation or evaluation documents when relevant.

Use `rg --files` and targeted `rg` searches before opening large files. Distinguish current implementation from plans, deprecated code, generated files, and historical documents. Do not expose secrets from environment or credential files.

Build a curriculum of 5–10 project-specific domains. Typical domains include architecture, request/data flow, core modules, persistence, integration boundaries, reliability, security, testing, deployment, and trade-offs, but include only domains supported by the project.

For every domain, retain:

- the concept to learn;
- the authoritative files and symbols;
- why it matters;
- one practical verification exercise;
- confidence or unresolved ambiguity.

## 3. Choose the learning mode

Infer the mode from the request:

- **Overview**: explain the project and its end-to-end flow.
- **Guided learning**: teach one domain at a time, then check understanding.
- **Code walkthrough**: follow a concrete request, event, or data object through code.
- **Knowledge check**: ask source-backed questions and score answers.
- **Study plan**: produce an ordered curriculum with estimated depth, not invented time promises.

If the user did not choose, begin with a compact project map and recommend the next domain. Do not force a questionnaire.

## 4. Teach interactively

For each lesson:

1. Explain the concept in plain language.
2. Connect it to actual files, symbols, configuration, and tests.
3. Show the end-to-end relationship before local details.
4. Highlight design rationale, alternatives, failure modes, and operational consequences.
5. Give one small command, trace exercise, or code-reading task when useful.
6. Ask one focused check question only when the mode is interactive.

During knowledge checks, ask one question at a time. Use at most three follow-ups, based on the user’s answer:

1. implementation detail;
2. design trade-off;
3. failure, debugging, or extension scenario.

Do not reveal the full answer before the user responds. Accept “skip” or “结束” immediately.

## 5. Evaluate with evidence

After a question or lesson, summarize:

- what the user understood;
- what was missing or inaccurate;
- the corrected source-backed explanation;
- 2–5 next files to read;
- one next exercise.

For scored checks, score each dimension from 1–10:

- factual accuracy;
- code grounding;
- architectural reasoning;
- trade-off and failure analysis.

Explain every score with evidence. Do not penalize a user for details that the repository itself does not establish.

## 6. Progress handling

Keep progress in the conversation by default. Do not modify the repository merely to track learning.

Persist progress only when the user asks. Use the path they specify; otherwise propose `.codex/project-learning.md` inside the target project and obtain confirmation before creating it. Record the project identity, inspected revision when available, completed domains, scores, weak areas, and next recommendation. Never store secrets or large source excerpts.

## Output rules

- Match the user’s language.
- Use clickable absolute file links with line numbers when possible.
- Label facts as **verified**, **user-provided**, or **inferred** when provenance matters.
- Prefer a compact map over a generic technology lecture.
- If source evidence conflicts, explain the conflict instead of choosing silently.

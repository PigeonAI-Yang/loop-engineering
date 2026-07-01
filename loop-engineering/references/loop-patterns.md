# Loop Patterns

Use the smallest loop that can be verified.

## capability-task

Use for repos that already have plans, task ledgers, issues, or failing tests.

Pattern:

```text
recall project purpose anchor -> task row -> inspect owned files -> implement
-> END-TO-END gate (not unit test) -> update ledger/report
```

The first and last steps are what separate this from rote task-chasing.

Before implementing, recall *why the software exists* (the Project Purpose in
the profile) and check the task advances it.

Before reporting done, run an **end-to-end gate**, not just a unit test. The
difference: a unit test calls the new function directly and proves the function
works. An end-to-end gate runs the real production path (or a faithful slice of
it) and proves the new output **actually appears where the next link reads it**.
If the new function only gets called from `#[cfg(test)]`, the end-to-end gate
fails — the task is an orphan, not done, regardless of how green its unit tests
are. Wire it into the runtime, or move it back to pending. Do not mark done.

A task whose output has no runtime consumer is an orphan even if its unit tests
are green. This is the single most common false-done failure mode: code that
works in isolation but is never reached by the running system.

Do not use this loop when the task source is vague or no end-to-end gate is
possible — if you cannot prove the downstream consumes the output, you cannot
verify the task.

## plan-integrity

Use before a long coding task.

Pattern:

```text
plan -> task ledger -> allowed files -> verification -> stop conditions -> acceptance
```

This loop should fail fast when a plan lets an agent claim partial work as done.

## regression

Use before merge, release, or broad refactor.

Pattern:

```text
project-wide gate -> focused failure isolation -> report -> no code change unless asked
```

Regression loops should not silently rewrite product behavior.

## source-health

Use for projects that depend on live websites, APIs, feeds, databases, or browser state.

Pattern:

```text
source catalog -> fetch/read -> archive/readback -> typed gap or complete -> report
```

Source health is not product completion. It only proves whether the input layer is alive.

## frontend-contract

Use for frontend work that consumes backend contracts or view models.

Pattern:

```text
API/view model -> render states -> smoke -> screenshot if needed -> human visual acceptance
```

Automated checks can prove runtime and state coverage. They cannot prove high-fidelity visual quality unless the project defines a visual oracle.

## release-closure

Use at the end of a feature.

Pattern:

```text
focused gates -> global gate -> ledger/changelog -> git status -> commit/push if requested
```

Never use release closure to upgrade a partial capability into product completion without the project's completion authority.

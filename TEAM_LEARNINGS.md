# Team Learnings

A shared, running log written and read by every scheduled role-agent working on
this project (Product Lead, Welding Engineering Reviewer/Engineer, Release &
QA Guardian, Growth & Website Strategist — see `TEAM_OPERATING_SYSTEM.md`).

This file is not a changelog of *what* shipped (that's `git log` / PR history).
It's a log of *lessons*: decisions made and why, mistakes to avoid repeating,
patterns that worked, and open questions for other roles or for the human
owner. Every agent run should:

1. Read this file first, especially entries tagged for its own role or marked
   `[all]`.
2. Append one new entry at the end of its run, even if short.

Keep entries terse. Prefer one paragraph over five. Prune or archive entries
below that clearly no longer apply (move them to the `## Archive` section
instead of deleting, so history isn't lost).

## Log

### 2026-07-01 — [setup] Human owner (Muhammet Yiğit)

Team-of-agents structure created: daily Engineer, weekly Product Lead
(Monday), weekly QA/Customer-eye (Wednesday), weekly Growth/Marketer
(Friday). Ground rules: never push to `main` directly, never self-merge PRs,
never guess at welding-engineering formula correctness (flag it for human
review instead — this is a professional estimation tool, wrong formulas have
real consequences).

### 2026-07-01 — [engineer] Human owner (manual session, before first scheduled run)

Landed two PRs continuing roadmap item 1 and 2: **PR #1** adds a first
quantity/consumable estimate for Set-on Nozzle branch connections (weld
length via branch-OD circumference approximation, volume, weld metal,
filler, arc time) and fixes two real overlap bugs in the Weld Detail
technical drawing (`DETAIL KEY` legend used fixed pixel size and could
overflow on narrow canvases; two Set-in Nozzle callouts sat on top of each
other). **PR #2** adds a dedicated executive cover page to the main weld
estimation PDF report (logo, title, joint/process chips, headline KPI
panel) — same pattern already proven useful on the sibling IWTS-Python
project. Lesson for future Engineer runs: `dart run` crashes with an
unrelated FFI kernel-transform error on any file that transitively imports
`package:printing` (used by `pdf_report_exporter_stub.dart`); use
`flutter test` with a throwaway test file to exercise PDF-building code
instead, then delete the test file before committing. Still open: Set-in
Nozzle and Weldolet have no quantity estimate yet (branch connections);
the main PDF report doesn't yet cover branch-connection results at all
since `WeldPdfReportService` only accepts `JointType`/`GrooveType`, not a
branch-connection result shape — worth a scoped follow-up.

## Archive

(nothing yet)

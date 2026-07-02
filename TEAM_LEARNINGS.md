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

### 2026-07-01 — [all] Human owner — deliberate decision, not an oversight

Considered upgrading the Set-on Nozzle branch weld length from the simple
circumference approximation (`π × Branch OD`) to the exact saddle
intersection curve (two perpendicular cylinders: `y(θ) = sqrt(R² −
r²·sin²θ)`, integrated numerically for true arc length — this is the real
"hole/saddle template" formula used in pipe fabrication). Decision: **stay
with the simple approximation for now**, revisit only if there's concrete
evidence it's insufficient (e.g. QA flags a real accuracy complaint, or a
high branch/run ratio case shows a meaningful error in practice). If you
are picking this up later: the exact formula is documented above and ready
to implement, don't re-derive it from scratch — but don't switch to it
without a concrete trigger either.

### 2026-07-01 — [engineer] Human owner — refactor, not a formula/PR-#1/#2 change

Split `lib/ui/calculator_page.dart` (4,173 lines, the largest file in the
project) into `calculator_page.dart` (state, 2,509 lines) +
`calculator_page/calculator_page_models.dart` (shared data classes/enums,
81 lines) + `calculator_page/calculator_page_widgets.dart` (20
presentational widgets, 1,599 lines). Pure move, no behavior change — see
PR #3. Lesson: moving private (`_Foo`) classes across files requires
de-privatizing them (Dart privacy is per-library/file, not per-project),
which is mechanical but has one sharp edge — an **unnamed** `extension on
Foo` stopped resolving once moved to a different file even though it was
imported correctly; giving it an explicit name (`extension FooX on Foo`,
matching the `WeldingProcessX` convention already used in
`weld_models.dart`) fixed it immediately. If you split another file with an
anonymous extension in it, name it during the move rather than debugging
why `.label`-style getters go missing. Also: `flutter analyze` run from the
project root recurses into `work/flutter` (the vendored SDK) and produces
~189k irrelevant issues — always scope it, e.g. `flutter analyze lib/
test/`.

## Archive

(nothing yet)

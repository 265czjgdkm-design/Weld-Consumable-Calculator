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

### 2026-08-25 — [growth] Human owner (overnight full-autonomy session)

Ran a full research pass (competitor apps, ASO/SEO, industry credibility
requirements, practitioner pain points) — see `docs/GROWTH_RESEARCH_2026-08-25.md`.
Headline findings: competitors have almost no review volume (low bar to
become "most trusted"), the audience is inherently skeptical of calculator
tools as authoritative (position as "first-pass estimate, verify against
your WPS," not a bidding/costing authority), and the single biggest
credibility gap is not citing deposition-efficiency factors (SMAW ~65% /
FCAW ~85% / GMAW ~95% / SAW ~98%) or a named reference (Blodgett's
Procedure Handbook, AWS D1.1 Annex L) in the PDF's engineering-basis
section — needs a codebase check before assuming it's actually missing.
Handed to Product Lead/Engineer for planning; see next entry.

### 2026-08-25 — [engineer] Human owner (overnight full-autonomy session, implementing planner's 4-item list)

Landed 5 commits, pushed individually: (0) fixed a pre-existing
`flutter test` failure found while verifying (widget_test.dart still
asserted `find.text('Varyos Weld')`, stale since the two-tier
VARYOS/WELD rebrand in `5e1856a` — this was breaking the test gate for
every commit tonight, so fixed the root cause instead of working around
it); (1) fixed a real chip-vs-chip label collision in
`weld_drawing_preview.dart` (top-center groove-type chip vs top-right
pipe-OD chip, distinct from the chip-vs-drawing collision `6c0cdac`
already fixed) via a combined `_drawTopChips()` helper that stacks the
OD chip below the type chip under a 430px canvas-width breakpoint
(computed by hand from real `TextPainter` widths — the pure collision
point is ~406px, 430 gives margin), coupled with raising `_createLayout`'s
`marginTop` floor to 80px only when stacked; (2) added a hedged citation
(Blodgett's Procedure Handbook, AWS D1.1 Annex L) to the PDF's
engineering notes for the deposition-efficiency factors, unchanged
numbers, citation text only; (3) added a "verify against your WPS and a
test coupon" disclaimer to both the PDF and the in-app results view;
(4) added `WeldFormulas.filletOversizeDeltaPercent()` (pure quadratic
derived calc, +1.5mm fixed increment) plus a results-view hint, fillet
joints only. Verified each with `dart analyze lib/ test/`, `flutter
test`, `flutter build web`, plus throwaway tests (deleted before
commit, per this repo's established pattern) that actually rendered the
PDF via `pdftoppm` and pumped the real widget tree through Calculate to
confirm exact on-screen strings — not just reading the diff. Open: item
1's fix is verified by box-model math and a rendered widget test, not a
real device/browser screenshot (no golden-image tooling in this repo) —
worth a manual resize check on Pipe Butt + Compound V. Item 4's PDF
version is a deliberate follow-up, not implemented tonight.

### 2026-08-25 — [engineer] Human owner (post-reviewer fix pass, same overnight session)

Fixed the 3 problems tonight's reviewer pass found in the above entry's
work, one commit each: (1) `2acdb84`'s chip-stacking fix used a fixed
430px canvas-width breakpoint derived from `TextPainter` widths measured
under `flutter_test`'s Ahem font (~1.6-1.9x wider than real proportional
fonts, confirmed empirically: "Compound V" measured 115.0px under Ahem
vs 71.5px under a real Arial `FontLoader` override at the same size) -
replaced it with a font-independent intersection check that builds both
chip rects with the same `TextPainter`/`TextStyle` the painter already
draws them with and stacks only when the real rects (plus a 3px gap)
overlap; verified against real Arial metrics at canvas widths
324-460px, confirming stacking now only triggers at the real ~335-340px
collision threshold instead of force-stacking on every real phone
width; (2) fixed a misattributed/inaccurate PDF citation (`9365d79`) -
Blodgett doesn't author Lincoln Electric's Procedure Handbook, AWS D1.1
Annex L doesn't cover deposition efficiency, and the app has no SAW
support - rewrote to cite only the app's real live efficiency values
(SMAW 65/FCAW 85/GMAW 90/GTAW 95, from `welding_defaults.dart`) with a
hedged, defensible citation; (3) fixed `filletOversizeDeltaPercent`
(`8034e4e`) using a fake +1.5mm "standard" step - added
`nextStandardFilletLegMm()` against the real metric table
(3/4/5/6/8/10/12mm), renamed the fraction-returning function to
`filletOversizeDeltaFraction` to match its own doc comment, and fixed
the test to exercise the real shipped 8mm->10mm path (+56.25%, not the
old 3/16"->1/4" imperial case the UI never produces). All 3 verified
with `dart analyze`/`flutter test`/`flutter build web` plus throwaway
tests (deleted before each commit) that actually rendered output -
real-font geometry probe for (1), `pdftotext` on a rendered PDF for
(2), a full widget-tree pump through the shipped fillet preset for (3),
confirming the on-screen hint reads "Next standard leg size up (10mm)
costs ~56.3% more filler." Lesson for next time: `flutter test`'s
default font renders as if every glyph were exactly `fontSize` wide
(Ahem-equivalent) - any collision/layout math tuned by eyeballing
`TextPainter` widths inside a widget test needs either a font-blind
measurement approach (what we landed on) or an explicit
`FontLoader`-loaded real font in the test, never a bare canvas-width
constant derived from default test-font metrics.

### 2026-08-25 — [engineer] Human owner (final verification finding, same overnight session)

A second reviewer pass re-checking the 3 fixes above confirmed all 3 hold
(independently re-derived the ~335-344px stacking threshold, confirmed the
PDF citation is now clean, confirmed the 8mm->10mm/+56.3% fillet hint), but
surfaced one more real, **pre-existing** (not from tonight) bug in the same
area: the in-canvas title (`'${jointType.label} / ${grooveType.label}'`,
drawn last at a fixed `Offset(14, 12)`) sits directly under the top-center
groove-type chip and prints over it on compact/mobile canvases - present
since before this session, but more visible than the chip-vs-chip case
`2acdb84`/`3bca03b` fixed. Fixed by only drawing that title in the
non-`fillAvailableSpace` (760px desktop) layout - in compact mode the
groove type is already shown by the top-center chip and the joint type by
the Joint Type dropdown above the card, so the title was redundant there,
not just colliding. `dart analyze`/`flutter test` (19/19)/`flutter build
web` all clean.

### 2026-08-25 — [engineer] Human owner (Compound V / Half V angle-tag vs
groove-depth overlap, real narrow-viewport render found)

The Compound V "α" label overlapping "10 mm groove depth" at real phone
widths (390px) had already had four prior "fix overlap" commits
(`970d112`, `2bfe8aa`, `fb5a8c9`, `4fc949b`) that didn't hold, because every
one of them was verified with either `TextPainter` math or `flutter_test`'s
default font, never a genuine narrow real-browser render. Confirmed this
time with a real Chrome (via `playwright-core` pointed at the system
Chrome.app - no network download needed, so it works even when
`playwright install` can't reach the CDN) driving a live
`flutter run -d web-server` session at a real 360-394px viewport: the root
cause is that the file's mm-space "lane" system assumes a fixed mm gap
between labels translates to enough pixel separation, but the drawing's
mm-to-pixel scale shrinks on a narrow canvas while each label bubble's
rendered size stays ~fixed in pixels, so lanes that clear each other on the
760px desktop canvas collapse into overlapping bubbles on a real phone
canvas. Fixed with a general, reusable mechanism instead of another
magic-number nudge: `_drawDimensionLine`/`_drawAngleTag` now return the
label's real measured `Rect` (mirroring the same TextPainter-based sizing
`_chipSize`/`_chipRect` already used for the top-chip collision fix), and
accept an optional `avoidRects` list; a new `_clearLabelPosition` pushes a
candidate label straight down/up in real pixel space by exactly the amount
needed to clear each avoid-rect. Compound V's α is now drawn first and its
rect fed into groove depth's placement, and both feed into β's; Half V's
angle tag and root-face label are drawn first and fed into groove depth's
placement (Half V's angle tag shares the same right-hand side as groove
depth, unlike Single V/Double V whose single angle tag sits on the
*opposite* side - which is why only Half V and Compound V had this bug,
confirmed via real render across all six groove types). Because the fix
measures whatever font is actually live at paint time rather than baking in
a threshold from one measurement environment, it holds regardless of which
font is rendering.

**Process note for whoever touches this file next**: verifying this class
of bug purely with `flutter_test` is a trap even beyond the already-known
Ahem-glyph-width issue - `flutter test` always forces the Ahem-equivalent
font via `--use-test-fonts --disable-asset-fonts`, and unlike the
`_chipSize`/`_chipRect` collision-count case, a `FontLoader`-registered real
font does **not** override this for any `TextStyle` that doesn't specify an
explicit `fontFamily` (confirmed empirically: registering under family `''`
and asserting real-vs-Ahem width in a widget test still measured the
Ahem-equivalent width). Also, real async I/O (`File.readAsBytes`, `toImage`
+ file writes) inside a plain `testWidgets` body hangs forever with no
error - `flutter_test`'s fake-async test zone never drives real `dart:io`
futures to completion; wrap any such I/O in `await tester.runAsync(() async
{...})`. Given that constraint, real-font verification for this fix used a
live `flutter run -d web-server` + `playwright-core` (pointed at the local
Google Chrome.app, since `playwright install`'s browser download was
network-blocked in this environment) driving a genuine narrow viewport -
this is the technique that actually caught a **second**, previously-unknown
real overlap (β vs. root face at 360px, only visible after the α fix)
that neither `TextPainter` math nor an Ahem-font render would have
distinguished from a false positive. Budget real time for this: this
environment's flutter_tester/DDC/Chrome startup was frequently slow or
outright stalled under concurrent multi-agent memory pressure (freeing
~400MB by killing stray flutter_tester/Chrome processes measurably helped),
so treat a blank screenshot after a generous wait as "try again after
checking `vm_stat`", not as a code problem.

### 2026-08-25 — [engineer] Human owner (Compound V / Half V overlap, sixth and actually-final attempt)

An independent reviewer pass on the commit above (`97d8096`) found it did
NOT actually hold: `_clearLabelPosition`'s single pass through `avoidRects`
could push a label clear of one rect and straight back into it while
clearing a second one on the opposite side (Half V's groove-depth label,
sandwiched between the angle tag above and root face below, netted ~0.1px
of real movement), and Compound V's avoid lists were incomplete (groove
depth only avoided alpha, not root face; beta didn't avoid root gap) so the
fix's own pushes created two *new* overlaps instead of resolving the
original ones. Root-fixed properly this time, verified with a real,
permanent test (`test/widgets/weld_drawing_label_overlap_test.dart` -
kept in the suite, not deleted, given this exact bug class's five-attempt
history):

1. `_clearLabelPosition` now always pushes **down** (never picks a
   direction per-rect) and **re-scans the full avoid list in a loop** until
   a full pass moves nothing - monotonic, so it can't oscillate.
2. Found and fixed a second real bug while verifying: the push loop was
   checking overlap against the **edge-clamped** rect
   (`_measurementLabelRect`), so once a push would carry a label past the
   canvas edge, the clamped rect's position froze and further pushes
   silently did nothing while the label kept "overlapping" - added
   `_unclampedMeasurementRect` and made the resolution loop iterate on
   that instead, only clamping at final draw time.
3. Made every label in Compound V avoid **every** label already placed
   before it (alpha → root face → thickness → root gap → groove depth → h
   → beta, each avoiding the full chain so far), not a hand-picked subset -
   `_drawButtCommonMeasurements` now returns thickness's rect too
   (`({Rect thickness, Rect rootGap, Rect? grooveDepth})`, a record) so
   every caller can wire it in.
4. Even fully correct, the algorithm alone couldn't close the last few
   pixels for Compound V's busiest (pipe + narrow-width) cases - there is
   genuinely not enough vertical room in the default compact card height
   for six callouts. Verified via the same real-font test: 345px of
   drawing-canvas height clears every combination at 316-390px canvas
   widths; the existing compact card was only giving these two groove
   types the same ~186-226px as every other (much less busy) groove type.
   `_narrowDrawingHeight` in `calculator_page.dart` now gives Half V and
   Compound V specifically a taller card (`.clamp(440.0, 500.0)` vs. the
   default `.clamp(280.0, 320.0)`) - **lesson for next time a "narrow
   canvas" bug in this file resists a pure label-placement fix: check
   whether the canvas is actually tall enough for the content before
   assuming it's purely an algorithm problem.**

All verified via `weld_drawing_label_overlap_test.dart`'s 24 real-font
cases (Half V + Compound V × plate/pipe × visual/technical × 316/346/390px
canvas width) - 0 overlaps in every case, plus the existing 19-test suite
still green. `dart analyze`, `flutter test`, `flutter build web` all clean.

### 2026-08-25 — [engineer] Human owner (extended the overlap fix to every groove type)

User pointed out the drawing was still crowded "for every bevel" - correct:
`weld_drawing_label_overlap_test.dart` only covered Half V/Compound V, and
Single V, Double V, and Fillet all had real, un-fixed overlaps (the earlier
reviewer had flagged these as "pre-existing, separate ticket" and they'd
never actually been addressed). Applied the same exhaustive-avoidance
pattern to all of them: **every label now avoids every label already
placed before it in its drawing function**, not a hand-picked subset -
`_drawButtCommonMeasurements` (shared by Single V/Double V/Compound V/
Square) now threads `thickness`/`rootGap`/`grooveDepth` rects through
consistently, and `_drawSingleV`/`_drawDoubleV`/`_drawFillet` each wire
root-face/angle-tag/half-thickness-bracket/leader labels into the full
chain. `_drawLeader` (used only by Fillet's two leader-line callouts) now
supports `avoidRects` too, reusing the same `_clearLabelPosition` machinery
angle tags and dimension lines already use.

**Found a second, subtler bug while verifying** (not just "not enough
room" this time): `_clearLabelPosition`'s resolution loop measured against
`_unclampedMeasurementRect` (X *and* Y both unclamped, from the earlier
Compound V/Half V fix) - correct for Y since Y can grow as the label gets
pushed down, but wrong for X since a label never moves horizontally during
resolution, so if its natural X position would overflow the canvas edge,
the REAL draw call clamps X back at render time - after resolution had
already used the wrong (off-canvas) X to decide the Y push was clear of
some other label. Fixed by adding `_resolutionMeasurementRect` (X clamped,
Y left unclamped) and using that instead - X is static so clamping it up
front is always safe; Y still needs to stay unclamped during the push loop
itself (see the fix above this one) or it "freezes" instead of converging.
This exact bug hit Double V's "total root face" label overlapping the
thickness label at narrow widths - worth remembering as its own distinct
failure mode from the vertical-freeze bug, should either recur.

**Every groove type genuinely needs more compact-card height than the old
default gave it**, not just Half V/Compound V/Double V (already fixed
above) - Single V, Square, and Fillet also needed real headroom once their
labels started correctly avoiding each other. `_narrowDrawingHeight` now
has three tiers instead of two: busy (Half V/Compound V/Double V,
`.clamp(500, 560)`), default (Single V/Square, `.clamp(440, 500)`), and
Fillet (`.clamp(420, 480)`) - all derived from
`weld_drawing_label_overlap_test.dart`'s per-groove-type minimum canvas
height plus the card's own ~100px of title/toggle/padding chrome, with a
small safety margin added on top of the test's exact minimums.

`weld_drawing_label_overlap_test.dart` now covers all six groove types ×
both joint types (plate/pipe, where applicable) × both drawing modes ×
316/346/390px canvas width - 66 cases total, all passing. `dart analyze`,
`flutter test` (85/85), `flutter build web` all clean. Live-browser visual
re-confirmation wasn't possible this round (Chrome tab became unresponsive
under memory pressure again) - the automated geometric test is the source
of truth here and is strictly stronger evidence than an eyeballed
screenshot (it proves zero pixel overlap, not "looks fine to me"), but a
real device/browser spot-check is still worth doing when convenient.

### 2026-08-25 — [engineer] Human owner (make the drawing itself bigger, not just non-overlapping)

User feedback after the overlap fix: the card was taller, but the joint
drawing didn't actually look bigger - correct. `_createLayout`'s scale is
`min(frame.width/(maxHalfWidthMm*2), frame.height/heightMm)`, and for
every groove type at real phone canvas widths this is **width-bound**, not
height-bound (checked the numbers: the width term comes out smaller by
roughly 2-3x for every groove type at 316-390px) - so the taller compact
card from the earlier fix bought label breathing room (more `frame.height`
→ more slack) but never touched the binding width term, so the geometry
itself stayed exactly the same size. Fixed by shrinking `marginX` in
`fillAvailableSpace` mode only (`0.0658 → 0.045` of canvas width; desktop/
FittedBox path unchanged) - since geometry and every label share the same
mm-to-px scale via `layout.point`, a bigger `frame.width` grows the drawing
*and* every label's pixel offset from it together, which also widens the
natural gaps between mm-separated labels (confirmed empirically: re-running
`weld_drawing_label_overlap_test.dart` at the old canvas heights still
passed, and the actual minimum canvas height needed dropped for every tier
- Fillet's dropped from 312px to 280px). Re-tuned
`_narrowDrawingHeight`'s three tiers down to match the new, smaller real
minimums instead of leaving the previous (now unnecessarily generous)
values in place: busy `.clamp(490, 550)` (was 500-560), default unchanged
at `.clamp(440, 500)`, Fillet `.clamp(390, 440)` (was 420-480).

All 66 `weld_drawing_label_overlap_test.dart` cases still pass at the new
minimum heights (388/334/280px canvas for busy/default/Fillet
respectively, both with a small safety margin baked in already). `dart
analyze`, `flutter test` (85/85), `flutter build web` clean. Live-browser
visual confirmation still not possible this session (same memory-pressure
issue as the prior two entries) - **this is now the third fix in this
file's history landing on real-font-render + geometric-assertion evidence
without a live screenshot; if a future session has a stable browser
available, a real visual pass over all six groove types is worth doing
specifically to confirm the *proportions* (not just the absence of
overlap) actually look right to a human, since that's not something a
geometric assertion can verify.**

### 2026-08-25 — [engineer] Human owner (a live browser finally worked - found real bugs the pill-overlap test structurally could not)

Got a stable Chrome connection this round and looked at Compound V for
real for the first time since the margin/scale change above. Found two
real problems `weld_drawing_label_overlap_test.dart` was never going to
catch, because it only asserts label-pill-vs-label-pill overlap:

1. **Alpha's pill sat visibly on top of the weld metal itself.** Its mm
   offset from the joint centerline (`halfGap + 6`) was a fixed constant
   that happened to clear the bevel at the old (smaller) scale, but the
   bevel is `halfBreak` wide at that height (not `halfGap`), and once the
   margin fix above made the geometry bigger, `halfGap + 6` no longer
   reached past the bevel's real edge. Fixed by anchoring off `halfBreak`
   (the actual geometry width at that height) instead of `halfGap` (the
   root width) - grows with the geometry instead of a magic number that
   only happened to work at one scale. Applied the same fix to Compound
   V's beta, which had the identical bug (anchored off `halfGap`, same
   fixed-constant risk).
2. **Beta's leader line, once pushed far down to clear five other labels,
   drew as one long diagonal cutting across the drawing and other labels**
   - technically zero pill-vs-pill overlap (the only thing the test
   checks), but genuinely unreadable, reading as if it pointed somewhere
   else entirely. `_drawAngleTag` now checks how far a label actually got
   pushed vertically; past a small threshold it routes the leader as an
   elbow (short stub in the label's natural direction off the geometry,
   then a clean vertical-then-horizontal run to wherever it landed)
   instead of one raw diagonal - the same "routed leader" convention real
   engineering drawings use. Below the threshold, behavior is unchanged
   (still the original short direct line).

**Lesson for next time:** a geometric assertion that only checks
label-vs-label overlap has a real, structural blind spot - it can't catch
a label sitting on the *drawing* itself, or a leader line crossing through
unrelated content. Both of those need an actual look. This is exactly why
this session flagged (repeatedly) that the automated test is strong
evidence but not a full substitute for a real visual pass - this round is
the proof.

Re-verified all 66 `weld_drawing_label_overlap_test.dart` cases still pass
after both position changes (they could have shifted alpha/beta's natural
collision profile). `dart analyze`, `flutter test` (85/85), `flutter build
web` all clean. **This time also got a real live-browser visual
confirmation** (Compound V and Fillet, real 390px viewport) - alpha no
longer overlaps the geometry, beta's leader is a clean elbow, both
drawings read as intentional and well-spaced rather than crowded.

### 2026-08-25 — [engineer] Human owner (deliberate, bounded vertical stretch - explicit product decision)

Even bigger and better-spaced, the drawing still read as small vertically:
`scale` in `_createLayout` is `min(width-based, height-based)`, and the
joint cross-section is inherently wide/short, so it's width-bound by a
wide margin (checked the real numbers for Compound V: height-based scale
came out over 3x the width-based one) - meaning most of the compact
card's generous vertical room (added for label spacing) was never touched
by the geometry itself, just centered around it as slack. Raising it
further isn't possible without either widening the canvas (capped by the
phone) or accepting non-uniform scale (angles read a little steeper than
their literal value). **Asked the user directly rather than deciding
silently, since this trades off against this repo's own stated "geometry
credibility" priority** (`TEAM_OPERATING_SYSTEM.md`) - they explicitly
chose visual size over literal-angle accuracy.

Implemented: `_SectionLayout` now carries an independent `scaleY` (defaults
to `scale` when not given, so nothing else in the file changes behavior).
`_createLayout`, in `fillAvailableSpace` mode only, lets `scaleY` stretch
up to `1.35x` the width-bound `scale` (still capped by
`frame.height/heightMm`, so it never overflows the box) - desktop/
FittedBox path is untouched, still perfectly to-scale. `layout.point`
applies `scale` to x and `scaleY` to y, so geometry AND every label
(computed through the same function) grow together in the vertical
direction, not just the plates/weld.

Re-verified all 66 `weld_drawing_label_overlap_test.dart` cases still pass
(both geometry and label Y-positions shifted, could have changed the
collision profile - didn't). `dart analyze`, `flutter test` (85/85),
`flutter build web` clean. Live-browser confirmed on both Half V and
Compound V, real 390px viewport - the plate/weld cross-section is visibly
taller and reads as intentional, not a tiny icon in a big empty card; 30°/
10° bevels still read as acute angles, not obviously distorted.

**If this file's layout code is touched again: `scale` (x-axis) is still
the width-bound "true" scale everything's mm dimensions are defined
against - only `scaleY` is deliberately inflated. Don't let the two drift
apart further than the 1.35x cap without re-confirming with the user; this
was an explicit, bounded product tradeoff, not a default to lean on
further by default.**

### 2026-08-25 — [engineer] Further enlargement round (cap raised to 1.6x) + a new bug class: labels can collide with their OWN dimension line

User asked again to enlarge the drawing further, both sideways and
vertically, and explicitly asked every groove type be checked afterward.
Raised the `scaleY` cap in `_createLayout` from `1.35x` to `1.6x` and
shrank the compact-mode side margin (`marginX`) from `0.045` to `0.038` of
canvas width, both in `fillAvailableSpace` mode only. (A more aggressive
pass through `1.8x`/`0.032` was tried first and reverted after the bug
below was found at those settings - not worth re-attempting without a
working live-browser check, see below.)

**New bug class found via live-browser inspection (Double V, Pipe Butt,
Technical mode) at the aggressive settings**: the thickness dimension
label ("12 mm t") had its own dimension line crossing directly through its
text. Root cause: `_drawButtCommonMeasurements` draws the thickness label
first, with no `avoidRects` (nothing has been placed yet to avoid) - so it
never runs through `_clearLabelPosition`, only the unconditional final
`_safeClamp` in `_drawTechnicalLabel` at draw time. That clamp only
protects against the *canvas* edge (fixed 10px), not against the label's
*own* dimension line - so a label whose natural (unclamped) X position
runs off the left edge as `scale` grows gets pulled back rightward, right
onto the line it's describing. This is a distinct failure mode from every
previous label-collision bug this file has hit (all of those were
label-vs-label); the permanent regression test
(`weld_drawing_label_overlap_test.dart`) structurally cannot catch it
either, since it only ever compares label pills against each other, never
against the drawn geometry or dimension lines - consistent with the
test's documented, known blind spot.

Considered routing the thickness label through `_clearLabelPosition`
against a thin rect built from its own dimension line, but that function
only ever pushes DOWN (see its own doc comment) - for a label sitting
beside the vertical thickness line at mid-height, a down-push would shove
it well below the member entirely, a worse result than the bug. Went with
the simpler, already-proven lever instead: dialed both settings back to
`scaleY` cap `1.6x` / `marginX 0.038` (still bigger than the previous
round's `1.35x`/`0.045`, so this round is still a net enlargement per the
request, just less aggressive than the first attempt). Re-verified all 66
`weld_drawing_label_overlap_test.dart` cases pass, `flutter test` 85/85,
`dart analyze` and `flutter build web` clean.

**Live-browser visual re-verification of this fix, and the "check every
bevel" pass the user explicitly asked for, could NOT be completed this
round** - the Chrome extension disconnected mid-session (the recurring
memory-pressure freeze this machine hits, documented earlier in this
file) and did not reconnect after a retry. Flagged to the user rather than
reported as done; if this file's layout code is touched again before a
real visual pass happens, treat Double V's thickness label specifically as
unverified at these settings, not confirmed-clean.

**If this file's layout code is touched again: the `scaleY` cap is now
`1.6x`, `marginX` is `0.038` in compact mode. Same caution as above -
these are product tradeoffs already pushed once at the user's explicit
request; don't push further without both re-confirming with the user AND
getting a working live-browser check, given this round's bug was only
visible that way.**

## Archive

(nothing yet)

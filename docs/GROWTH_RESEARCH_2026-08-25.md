# Growth Research — 2026-08-25

Research pass covering: competitor landscape, ASO/SEO discoverability, industry
credibility requirements, and practitioner pain points. Feeds Phase 3
("Website Productization") of `PRODUCT_ROADMAP.md` and the "Growth and
Website Strategist" role in `TEAM_OPERATING_SYSTEM.md`.

## 1. Competitor Landscape

The space is crowded but shallow — many small solo-dev apps, almost none with
meaningful review volume, and no single dominant player. Real opportunity
(low competition ceiling) but also a warning (low review counts often mean
low install/retention, i.e. the audience is hard to reach or hard to keep).

**Solo-dev / small-team calculator apps (closest direct competitors):**
- **WelderCalc** (iOS) — TIG/MIG/stick/flux-core amperage, heat input, travel
  speed, electrode sizing, filler calc. Freemium ($1.99/mo, $9.99/yr,
  $24.99 lifetime, or a "$139.99 Fab Shop Bundle"). Targets pipefitters,
  structural welders, fab shop guys, mobile welders, AWS-test students. No
  visible ratings yet.
- **Weldwise** (iOS) — free base app + one-time $6.99 Pro unlock (gas usage,
  filler cost analysis). Solo dev, 11 languages, no data collection. Its own
  copy tells users "Every value is a starting point... Always confirm
  against your WPS, the machine chart and a test coupon" — self-disclaims
  accuracy. No ratings yet.
- **WeldCalc Pro** (iOS) — free + subscription ($2/week or $20/year)
  unlocking FCAW calculator, preheat calculator, filler metal guide. No
  ratings yet.
- **Welding Weight and Cost Calc / Pro** (Android) — weld metal weight/cost,
  electrode requirement, filler metal requirement for butt/fillet joints —
  functionally closest to Varyos Weld's core scope. One surfaced review:
  "Could be a very useful app, if only it worked." No aggregate rating —
  reliability complaints on a tiny review base.
- **Welding Weight Calculator Pro**, **Welding Toolbox 2**, **Pocket Welder
  Helper**, **iWeld** — similar small utility apps, low-visibility, no
  independent web presence or rating data.

**Established brand/OEM tools (credibility benchmarks, not real competitive
threats — they push their own consumable brands):**
- **Lincoln Electric** — "Weld Parameter Guide" app (free, offline, smart
  lookup tables), also a "GearPoint" app and
  `welding-calculator.lincolnelectric.com` (appeared down during this check).
- **Miller Electric** — "Miller Weld Setting Calculator," free, **4.0★ from
  79 ratings** — the only competitor found with a real rating signal.
  Praise: correct settings for a particular electrode, useful for quick
  field reference while traveling. Complaints: wants dual-shield MIG
  settings, larger font, more wire-diameter coverage (0.030"). A separate
  independent review found a serious accuracy complaint: "wildly inaccurate
  amperage setting, app suggests 300-400 amps with 1/8" 6010 rod, in real
  life 85-105 amps" — even a big brand name doesn't guarantee accuracy
  trust.
- **ESAB** — "Quick Weld Productivity Analyzer" (web-based) computes weld
  metal weight/ft, cycle time, energy/consumables/labor cost, and generates
  a **PDF report with a QR code** linking back to the original inputs so
  users can regenerate variants — directly relevant prior art for Varyos
  Weld's own PDF-report positioning. Also has an "EXATON Welding" app.
- **voestalpine Böhler Welding** — Welding Calculator app (cooling time,
  preheat temp, filler metal quantity), free, Android+iOS.
- **Certilas ("WeldingPro")** — positions itself as "#1 Welding App in the
  World," combines cost + parameter calculators with AI advisory, filler
  material search, product cross-reference, certificate lookup, and B2B
  ordering. Most feature-complete competitor found, but tied to Certilas's
  own filler-metal catalog (vendor lock-in) — a gap Varyos Weld (vendor-
  neutral) can exploit.

**Practitioner skepticism worth internalizing** (Miller Welding Discussion
Forums, AWS forum): experienced users state flatly that "no program can
accurately calculate the cost of a job unless it's very small and simple,"
and real estimating expertise comes from years of study across hundreds of
variables. Both forums repeatedly cite Omer Blodgett's *Procedure Handbook
of Arc Welding* (Lincoln Electric) as the trusted reference, not any app.
**Single most important competitive-landscape finding**: the audience is
inherently distrustful of calculator tools as authoritative cost/estimate
sources — the winning positioning is "fast, standards-referenced first-pass
estimate to verify against your WPS," not "replaces your estimator's
judgment."

**Gaps Varyos Weld can win on:**
1. Almost no competitor has real review volume — the bar to become the
   "most trusted reviewed" app in this space is low if we can generate even
   a handful of good reviews.
2. Most competitors are parameter/settings calculators first,
   consumable-quantity/PDF-report second (or vice versa but ugly). Varyos
   Weld's PDF-report-first, branded-export focus is a real differentiator
   for the estimator/procurement persona (not the on-the-floor welder
   persona most competitors target).
3. No competitor found is vendor-neutral AND report-quality AND
   cross-platform (Flutter web+mobile) simultaneously.
4. Self-disclaiming copy ("starting point, confirm against WPS," used by
   Weldwise) validates that explicit accuracy disclaimers build trust in
   this market — worth adopting directly in Varyos Weld's UI/PDF language.

## 2. Discoverability / ASO + SEO Plan

**ASO keywords** (validated by repeated organic appearance across App
Store/Play Store search, not guessed): "welding calculator," "weld cost
calculator," "welding weight calculator," "electrode calculator," "filler
metal calculator," "weld consumable calculator," "MIG calculator," "TIG
calculator," "welding estimator," "weld metal weight," "arc time
calculator," "fillet weld calculator," "butt weld calculator." Long-tail,
lower-competition: "weld filler metal weight calculator," "welding
procurement estimator," "weld report PDF generator," "welding consumable
quantity calculator" (this exact phrase is the literal title of a real
Google Groups thread — confirms real practitioner search language).

**SEO for varyosweld.com**: `site/index.html` already has a reasonable meta
description, but per `PRODUCT_ROADMAP.md`'s unstarted Phase 3 there's no
blog/content layer yet. Target the exact long-tail queries surfaced here as
blog/landing content: "how to calculate weld metal weight," "SMAW vs GMAW
deposition efficiency," "how much welding wire do I need for a project,"
"AWS D1.1 filler metal requirements explained" — real searched phrases,
already ranked for by WeldingAnswers.com, TestTalkHQ, Kongfang Metal,
FIRGELLI — all using a "calculator + short explainer" pattern. Varyos
Weld's edge: a full app + PDF export behind the same content, not just a
static widget.

**Realistic organic/free channels** (per stated preference against paid
ads):
- **weldingweb.com** — active pro/enthusiast forum; a "share your tool, get
  feedback" post is legitimate, but the culture is skeptical of calculator
  tools — framing matters (see credibility section).
- **r/Welding** — no organic discussion of a "best welding app" found,
  suggesting an open, unclaimed opportunity for a non-spammy "I built a
  free weld consumable calculator, feedback welcome" post.
- **AWS Member Network / AWS local sections** and the **AWS forum**
  (app.aws.org/forum) — real, active threads exist specifically about weld
  cost calculators (tid=34197 "weld calculator," tid=16730 "Welding cost
  estimator now with Strength calculator") — a direct-hit community already
  discussing this exact need.
- **LinkedIn** — welding/fabrication estimator groups likely exist but were
  not independently verified by name this pass; worth a follow-up.
- **YouTube** — no dedicated "fabrication estimator" creators found; large
  general welding channels exist (Welding Tips And Tricks, 6061.com,
  Industrial & Welding Supply) but sponsorship/demo angles likely cost
  money or require relationship-building — lower priority given the
  free-channel preference.
- **Trade publications**: thefabricator.com and WeldingAnswers.com already
  rank/publish on this exact topic — a guest post or tool-mention pitch to
  either is a realistic free/low-cost PR angle.

## 3. Domain Credibility Requirements

- **AWS D1.1 (Structural Welding Code — Steel)**, latest edition
  D1.1/D1.1M:2025, is the primary structural-welding reference. Table 5.4
  (matching filler metal to base metal strength) and Annex L (filler metal
  strength properties) / Annex M are the relevant sections to reference or
  name-check in "engineering basis" language.
- **ASME Section IX** governs WPS/PQR qualification — the pressure-vessel/
  piping-industry companion to AWS D1.1. Worth a dedicated follow-up if
  ASME-specific terminology validation is wanted.
- **ISO 9606-1** covers welder qualification testing (filler material
  groups FM1–FM6) — tangential, relevant only if terminology needs to be
  internationally consistent.
- **Deposition efficiency is the single most load-bearing "did you get this
  right" number** for credibility, with a real, cited industry-standard
  range (multiple independent corroborating sources): **SMAW ≈ 63–65%,
  FCAW ≈ 83–87%, GMAW (solid wire) ≈ 92–98%, SAW/GTAW ≈ 98–99%.** If Varyos
  Weld's formulas don't already expose/cite these process-specific
  efficiency factors explicitly in the PDF's "basis" section, that's a
  concrete, verifiable engineering-reviewer action item — **needs a
  codebase check before being treated as confirmed new work** (see open
  questions).
- **The Procedure Handbook of Arc Welding (Blodgett/Lincoln Electric)** is
  the de facto trusted reference practitioners cite over any app or
  calculator — citing this handbook by name in the PDF's methodology/basis
  footer would materially raise trust versus citing nothing.
- **Expected accuracy disclaimer convention**: competitors that show any
  self-awareness (Weldwise) frame outputs as a **starting point requiring
  WPS/test-coupon verification**, not a final answer — mirror this in
  Varyos Weld's report footer/disclaimer language if not already present.
- **Terminology conventions** expected by a welding engineer reviewer: root
  face, root gap, bevel angle, groove angle, cap/reinforcement, leg length
  (fillet), throat, overwelding allowance — matches what
  `TEAM_OPERATING_SYSTEM.md` already flags as the Welding Engineering
  Reviewer's checklist (root face, gap, bevel, cap correctness) — confirms
  that checklist is aligned with real industry vocabulary.

## 4. Practitioner Voices

- **Google Groups "materials-welding" thread** — real practitioners actively
  requesting a standard tool for "pipe butt weld consumable quantity
  calculation." Concrete pain points: (1) manual calculation burden —
  everyone wants a pre-built tool rather than deriving formulas themselves;
  (2) no industry-standard template exists, so everyone reinvents it; (3)
  shared spreadsheets have unclear/undocumented input parameters ("ID means
  inch dia? ... deposition rate of SAW not given" — a UX lesson: label
  inputs unambiguously); (4) password-protected/gatekept spreadsheets
  frustrate users. **Strong signal**: a clean, well-labeled, non-gatekept,
  free tool with self-explanatory inputs directly answers a real, currently
  unmet request from this exact community.
- **WeldingAnswers.com's "6 Steps to Calculating Total Weld Needed"**
  (written by a certified welding engineer) — standard handbook tables bake
  in only a small (~10%) overwelding allowance, and a seemingly minor
  sizing mistake compounds badly — e.g. oversizing a 3/16" fillet to 1/4" is
  **77% more weld metal**, not proportional. Concrete feature idea: a tool
  that visibly warns/flags the cost impact of oversizing addresses a named
  real pain point.
- **AWS forum threads** (tid=34197, tid=16730) — confirmed to exist and be
  on-topic via search snippets; a follow-up session with browser-based
  access (WebFetch got 403'd) could pull full quotes.
- **Miller Welding Discussion Forums** — consensus: no automated tool
  substitutes for experience-based estimating on complex jobs, tools are
  useful only for "very small and simple" jobs. Implication: position
  Varyos Weld explicitly as a fast first-pass consumable-quantity and
  arc-time calculator (which it already is), not a bidding/costing
  authority — avoids triggering this exact skepticism.

## Top Opportunities (ranked)

1. Add explicit deposition-efficiency citations (SMAW 65% / FCAW 85% / GMAW
   95% / SAW 98%) and a named handbook/standard reference (Blodgett's
   Procedure Handbook, AWS D1.1 Annex L) to the PDF's engineering-basis
   section — closes the single biggest credibility gap, cheap if the
   formulas already use these factors internally (copy/labeling change).
2. Adopt explicit "starting point — verify against your qualified WPS/test
   coupon" disclaimer language in-app and in the PDF footer.
3. Add an "oversizing cost impact" flag/warning (e.g. surfacing that one
   fillet size up costs disproportionately more filler) — concrete,
   practitioner-sourced, demo-able.
4. Post to AWS forum threads (tid=34197, tid=16730) and AWS local
   section/Member Network channels once the tool is public.
5. Post to r/Welding and weldingweb.com with a "built this free tool,
   feedback welcome" framing — lead with the PDF-report/verification
   framing, not a bidding-tool claim, given forum skepticism.
6. Target long-tail SEO content once Phase 3 website work starts — proven
   searchable demand, beatable with a working tool behind the content.
7. Lean into vendor-neutrality as explicit positioning against Certilas.
8. Get even a handful of App Store/Play Store reviews early — nearly every
   direct competitor has zero/near-zero review volume, so a small genuine
   review base is a disproportionately large trust signal here.

## Open Questions for Planning

1. Does Varyos Weld's current calculator/PDF already cite deposition
   efficiency factors and a named standard/handbook, or is this a genuine
   gap? Needs a codebase check (`lib/services/weld_pdf_report_service.dart`,
   calculation service files) before treating it as new work.
2. Full-text access to the 403'd forum threads (AWS forum, eng-tips) would
   strengthen practitioner quotes if deeper detail is wanted later.
3. LinkedIn welding/fabrication groups were not independently verified by
   name — worth a targeted follow-up search.

## Confidence

High on competitor app details (fetched live App Store/Play Store pages)
and deposition-efficiency standard values (multiple independent
corroborating sources). Medium on forum-sourced practitioner quotes (some
primary threads returned HTTP 403 to WebFetch, relied on search-result
snippets). Low on LinkedIn groups (not independently verified by name).

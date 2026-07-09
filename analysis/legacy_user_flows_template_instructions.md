# Legacy User Flows Workbook Instructions

Use `analysis/legacy_user_flows_template.xlsx` to reverse-engineer legacy
behavior, plan the target migration through SDD, and later verify that the
new implementation preserves the intended behavior.

This workbook is not an implementation task list. It is an evidence and parity
matrix. Agents must not start coding from this workbook alone. Implementation
starts only after the user approves the relevant SDD/spec/plan/tasks.

## Constitution first (MUST — read before any action)

Before doing **anything** in this project — any workflow step, any flow, any
spec/plan/task, any code or workbook edit — the agent MUST first read and comply
with the project constitution at **`.specify/memory/constitution.md`**. The
constitution is authoritative and overrides convenience or local conventions; it
applies to every action from the very start, not just at implementation time.

- Treat its principles as hard constraints (e.g. no database mutation/seeding at
  startup, no magic strings/numbers, branch-first with `main` stable, evidence
  before replacement, automated tests, security hardening, documented
  deviations).
- If a requested action would conflict with the constitution, do not silently
  proceed: either revise the approach to comply, or surface the conflict and
  propose a constitution amendment (with rationale) for the owner to ratify.
- If the constitution file is missing or unratified, flag that and get it
  ratified before treating specs/plans/tasks as final.

## Required Workflow

1. **Collect legacy evidence from code first**
   - Inspect only the legacy source, deployable descriptors, configuration,
     database scripts, UI pages, controllers/servlets/actions, services, EJBs,
     jobs, messaging handlers, reports, and tests.
   - Record concrete file/class/page evidence in the workbook.
   - Prefer behavior that is visible to a user, operator, or external system.
   - Do not invent business requirements from names alone. If behavior is
     inferred, mark it as inferred in the notes/evidence.

2. **Re-analyze the completed workbook (mandatory once the sheet looks done)**
   - Treat the first evidence pass as a draft, not the finished product. Once
     the workbook is built, run a second, adversarial completeness audit: for
     each area, diff the captured rows against the legacy code and list
     user-visible behaviors still missing (whole new flows OR extra scenarios of
     an existing flow), then add the gaps you find. Real systems hide secondary
     flows (e.g. API/Basic-auth, mobile/WAP screens, file managers, admin/job
     endpoints, export variants) that a first pass misses.
   - Confirm grouping: each logical flow is exactly one collapsible group, and
     flows of the same feature live under one epic (no duplicate same-named
     banners, no flow split across IDs).
   - Confirm ordering: epics are ordered top-to-bottom in the intended
     implementation/dependency order — foundation first (people, roles,
     authentication, access control, platform/admin), then core domain, then
     supporting features, then interop last (import/export, external APIs,
     mobile) — so the sheet reads as the build order.
   - Do not consider the evidence step finished until this re-analysis surfaces
     no new gaps and the grouping/order checks pass.

3. **Write or update SDD before implementation**
   - Convert the discovered user-visible behavior into feature specs,
     clarifications, plans, and tasks.
   - Mark whether each workbook row is covered, deferred, or missed by SDD.
   - Do not implement code until the user explicitly approves the next
     implementation step.

4. **Implement only after user approval**
   - Work from approved SDD artifacts, not directly from the workbook.
   - Keep changes scoped to the approved feature/user story.
   - Add tests required by the project constitution and the feature plan.
   - **Migrations (constitution §VII):** if the change touches the EF model /
     `DbContext`, ALWAYS author a migration (`dotnet ef migrations add <Name>`)
     and commit it in the same PR — this is mandatory, not a judgement call.
     Then **apply it to the local development database in the same step**
     (`dotnet run --project backend -- --migrate`) so the owner can see and test
     the change. The schema is never migrated at app startup; `--migrate` is the
     explicit operator command. After pulling migration-bearing changes, run
     `--migrate` once or the new tables won't exist locally (authored ≠ applied).

5. **Verify target parity after implementation**
   - Revisit the workbook after the new code exists.
   - Fill destination columns with implemented status, notes, and code evidence.
   - Use the workbook to identify gaps between legacy behavior, SDD, and the
     target implementation.

6. **Reconcile SDD ↔ workbook and plan the next gaps (end of each milestone, and before "done")**
   - Sweep every `specs/NNN-*/tasks.md` and list the tasks still unchecked
     (`[ ]`). For each, decide: already delivered (so it should be ticked + its
     workbook row greened) or genuinely pending.
   - Keep tasks.md and the workbook in lockstep (constitution §XI task-sync):
     every delivered+tested flow is green / `[x]`; every still-orange row maps to
     an open, unchecked task — no half-states where one says done and the other
     doesn't.
   - **Epic roll-up colour:** make the whole epic/flow summary row green
     (all columns A–N, like UF-008) **only when every child scenario is green in
     both the Destination block (Destination implemented? = Yes) and the SDD block
     (Covered in SDD? = Yes and Deferred in SDD? = No)** — i.e. nothing inside is
     missed, deferred, or unimplemented. If any child is still orange/red or
     deferred, the epic row stays orange.
   - **Done rows go fully green (D–N).** Whenever a child scenario reaches
     done (Destination implemented + SDD covered, not deferred), green its
     whole data range D–N — including the source/requirement cells — so a
     completed flow has no leftover orange cells. Only the fill changes; the
     values stay. (See the detail-row colour rule under Workbook Structure.)
   - For the remaining unchecked tasks / orange rows, **re-run the analysis**
     (workbook rows + legacy evidence + the feature spec) to understand what each
     leftover actually requires and whether a dependency now exists, then turn
     those into the next implementation batch.
   - Repeat until no unchecked task remains without a clear reason (deferred /
     N/A with rationale), so nothing silently stays half-implemented.

## Workbook Structure

The workbook has one sheet: `User Flows`.

Rows 1-4 are title, notes, and color legend. Rows 5-6 are section headers and
column headers. Data entry starts at row 7.

Keep one row per atomic functional step. A broad use case can span multiple
rows, but each row should describe one checkable behavior.

### Row layout, grouping, and color

Use a three-level hierarchy — **Epic → Flow → Scenario** — laid out so that
expanding one epic reveals its whole picture at once. There are two physical
row types and a single Excel outline level:

- **Epic banner row** (outline level 0, one per epic): an epic is a coarse
  feature area that groups related flows (e.g. `Authentication & Login` groups
  valid/invalid login, remember-me, logout, login modules). Fill `Use Case ID`
  (A) with the epic id (`UF-001`...), the **epic name** in `Use Case` (B), the
  epic **status** in the `Scenario` column (C: `Passed`, `Not Passed - Missed`,
  or `Not Passed - Deferred/Partial`), and a short meaning of that status in
  column D. Leave the other columns blank. Color the whole banner row by status:
  red `FFEA9999` (Missed), orange `FFFCE4D6` (Deferred/Partial), green
  `FFE2F0D9` (Passed).
- **Detail rows** (outline level 1) — one per atomic, checkable behavior, listed
  directly under their epic so a single expand shows every flow and scenario:
  - `Use Case ID` (A) stays blank.
  - `Use Case` (B) holds the **flow name** (the lower-level use case, e.g.
    `Login with invalid credentials`). Write it once on the flow's first
    scenario row and leave B blank on that flow's remaining scenario rows, so
    each flow reads as a sub-block. Bold the flow name on its first row.
  - `Scenario` (C) holds `Happy path` / `Alternative path` / `Operational path`.
    Order the rows within each flow Happy → Alternative → Operational.
  - D–H carry requirement/description/expected/source; I–N stay blank until
    target/SDD review.
  - A, B and the Scenario cell sit on a light spine (`FFF8FAFC`); the data
    cells (D–N) take a status color. Initially the whole D–N range is the
    epic's status color (orange/red). As review progresses, the Destination
    block (I–K) and SDD block (L–N) are recolored per their own status.
  - **A fully-done scenario row is green across its entire data range D–N**
    (requirement/description/expected + source + destination + SDD), not just
    the I–K/L–N blocks — when it is implemented in the target (`Destination
    implemented? = Yes`) **and** covered in SDD (`Covered in SDD? = Yes`,
    `Deferred in SDD? = No`). Don't leave the source/requirement cells (D–H)
    orange under a done row; that reads as "half done" and is misleading. The
    cell *values* (e.g. `Source implemented?`) are unchanged — only the fill
    follows the row's done status. A/B/C stay on the light spine regardless.
- Use Excel **row outline grouping** so each epic collapses/expands on its own:
  detail rows at outline level 1, banner at level 0, with `summaryBelow = false`
  so the banner (the `+`/`-` control) sits **above** its detail rows. Open the
  workbook with every group collapsed (only the epic banners visible).

Never scatter the same flow across the sheet or across multiple IDs; all
scenarios of a flow are contiguous, and all flows of an epic sit in that epic's
one collapsible block. Until an epic has been reviewed against the target/SDD,
set its status to `Not Passed - Missed` (red); turn banners orange/green as work
lands and remove red as items are completed.

### Cell formatting (reproduce exactly)

Keep title/notes/legend/section/column-header rows (1–6) exactly as the template
ships them. For the data area (row 7 down), apply these styles so every agent
produces the same look:

- **Font:** `Carlito` everywhere (matches the template).
  - Epic banner cells: **bold, size 11**. Font color `FF7F0000` (dark red) on a
    red/Missed banner; use `FF1F2937` (dark slate) on orange/green/neutral
    banners.
  - Flow-name cell (column B, first scenario row of a flow): **bold, size 10**,
    color `FF1F2937`.
  - All other detail cells: regular, **size 10**, color `FF1F2937`.
- **Fills (solid):**
  - Whole banner row (A–N) = the status color: red `FFEA9999`, orange
    `FFFCE4D6`, green `FFE2F0D9`, or neutral white `FFFFFFFF`.
  - Detail rows: columns A, B and the `Scenario` cell (C) use the light spine
    `FFF8FAFC`; columns D–N use the epic's status color.
- **Borders:** thin `FFBFBFBF` on all four sides of every data cell.
- **Alignment:** `wrap_text = true`, vertical `top`, horizontal `left`.
- **Row height:** leave automatic (do not hard-set), so wrapped text is not
  clipped.
- **Outline:** banner rows `outlineLevel 0`, detail rows `outlineLevel 1`,
  `summaryBelow = false`; ship with detail rows hidden / banners collapsed.

## Columns

### Source / Legacy Code

`Use Case ID`
: Stable identifier for the **epic**, for example `UF-001`. One ID per epic;
it appears only on the epic banner row and is blank on the detail rows. Do NOT
mint a new ID per flow or per scenario.

`Use Case`
: Dual purpose by row type. On an **epic banner** it holds the epic name
(e.g. `Authentication & Login`). On a **detail row** it holds the **flow** name
— the lower-level use case (e.g. `Login with invalid credentials`) — written
once on the flow's first scenario row and left blank on the flow's remaining
rows. Group every scenario of a flow contiguously, and every flow of an epic
inside that epic's block.

`Scenario`
: Row classification inside the use case. Use this fixed vocabulary on the
detail rows (do NOT invent finer-grained labels):
  - `Happy path` — the primary successful flow a user/system follows.
  - `Alternative path` — any non-primary branch: input validation, authorization
    checks, error handling, and edge cases all go here (do not split them into
    separate `Validation`/`Authorization`/`Error handling`/`Edge case` labels).
  - `Operational path` — operator/admin/background behavior (scheduled jobs,
    notifications, cache/admin operations, batch flows).
: On a use-case **banner row** (see Workbook Structure) the Scenario column
instead holds the use-case status: `Passed`, `Not Passed - Missed`, or
`Not Passed - Deferred/Partial`.

`Functional requirement / step`
: A precise, testable behavior. Write it as a requirement, not as code.
Example: `Returning customer can sign in with valid credentials.`

`Business-readable description`
: Plain-language explanation of why the behavior exists and what it means for
the business/user flow.

`Expected user-visible result`
: What a user, admin, supplier, operator, or external caller can observe.
Examples: page shown, status changed, validation message displayed, order
queued, inventory updated, report refreshed.

`Source implemented?`
: Whether the legacy code implements this behavior. Use `Yes`, `No`,
`Partial`, or `Inferred`.

`Source code evidence`
: Concrete references to legacy evidence. Include file names, classes, pages,
routes, descriptors, database tables, queues/topics, or config keys. Use enough
detail that another agent can find the evidence without chat history.

### Destination / Target Implementation

`Destination implemented?`
: Whether the migrated/target system implements this behavior. Use `Yes`,
`No`, `Partial`, or `N/A`.

`Destination notes`
: Short explanation of the implementation state, intentional behavior changes,
known gaps, or test observations.

`Destination code evidence`
: Concrete target references: controller/component/service/test file names,
routes, migrations, database tables, UI paths, or test names.

### SDD Coverage

`Covered in SDD?`
: Whether the behavior is covered by an SDD artifact. Use `Yes`, `No`,
`Partial`, or `N/A`.

`Deferred in SDD?`
: Whether SDD explicitly defers the behavior. Use `Yes` only when a spec/plan
clearly marks it as out of scope, future work, or an intentional decision.

`SDD evidence`
: Reference the spec/plan/tasks file and, when useful, the requirement,
decision, user story, or task ID.

## Color Legend

Use row coloring to make review fast.

`Green`
: Fully covered. Legacy behavior exists, SDD covers it, target implementation
exists, and no unresolved parity gap remains.

`Red`
: Missed. Legacy behavior exists, but the target does not implement it and SDD
does not cover or defer it. These rows usually require a new SDD feature or a
user decision.

`Orange`
: Known gap, partial behavior, or planned/deferred behavior. Use this when the
gap is intentional, already captured in SDD, blocked by a decision, or only
partially implemented.

`White`
: Neutral/unclassified. Use for newly discovered rows before SDD/target review
is complete.

## Quality Rules

- Do not claim `Yes` without concrete evidence.
- Do not treat documentation as source truth when code contradicts it.
- Prefer small rows over giant bundled requirements.
- Preserve legacy vocabulary where it matters, but explain it in modern
business language.
- If the legacy behavior is unclear, write `Inferred` or `Partial` and explain
the uncertainty.
- If SDD intentionally changes behavior, mark the destination as implemented
only when the target implements the approved SDD behavior, and document the
legacy difference in notes.
- If a row is red, do not fix it directly in code. First create or update SDD
and ask the user for approval.

## Review Checklist

Before handing the workbook back:

- Every legacy behavior row has source evidence.
- Every destination `Yes` or `Partial` has target evidence.
- Every `Deferred in SDD? = Yes` has SDD evidence.
- Red rows are actionable and not vague.
- Orange rows explain the reason for partial/deferred status.
- The workbook can be understood without reading the chat history.

<!--
Sync Impact Report
1.0.0: Initial COBOL Core Banking modernization constitution.
Principles adapted from the XPlanner migration constitution:
- constitution-first/spec-driven workflow
- runnable legacy baseline
- evidence before replacement
- business-flow parity with documented deviations
- incremental migration
- branch-first/main-stable workflow
- explicit data mutation control
- automated verification
- clean code/no magic values
- workbook-driven coverage tracking
Project-specific additions:
- active COBOL file layout is the inline FD layout in the executable programs;
  ACCOUNTS.CPY is an unused/conflicting artifact until a spec reconciles it.
- legacy runtime is GnuCOBOL in Docker Compose; target stack is not selected yet.
Templates requiring updates:
- TODO: add .specify/templates/{spec,plan,tasks}-template.md if/when Spec Kit is
  initialized for this repo.
Follow-up items:
- Ratification by the project owner pending.
-->

# COBOL Core Banking Migration Constitution

Governs the analysis and future modernization of the legacy **COBOL Core
Banking** sample (`BANK-MAIN.CBL`, `INIT-DB.CBL`, `TRANS-PROC.CBL`,
`REPORT-GEN.CBL`, `ACCOUNTS.DAT`). It is authoritative: every spec, plan, task,
implementation, and workbook update must comply or explicitly propose an
amendment.

## Core Principles

### I. Constitution-First, Spec-Driven, Approval-Gated
This constitution is read before specs/plans/tasks are treated as final. No
modern replacement code is written before the relevant SDD artifacts exist and
the owner has explicitly approved moving to implementation. Specs describe
behavior and migration decisions, not just code structure.

### II. Runnable Legacy Baseline
The COBOL legacy baseline MUST stay runnable through Docker Compose:

```bash
docker compose run --rm core-banking
```

A change that breaks the terminal baseline is non-compliant unless it explicitly
replaces it with a verified equivalent. The server baseline lives at
`/opt/cobol-core-banking` and is used as a golden reference.

### III. Evidence Before Replacement
Legacy behavior is captured as evidence before a target equivalent is built. The
source of truth for legacy behavior is `analysis/legacy_user_flows.xlsx` with
code evidence, not memory and not README claims alone. Specs trace requirements
back to workbook epics/flows/scenarios.

### IV. Business-Flow Parity With Documented Deviations
Default goal is parity for every workbook row. Intentional improvements, such as
turning the vertical terminal report into a proper table or replacing runtime
file crashes with user-friendly errors, MUST be recorded as explicit deviations
in the spec and workbook notes. Deviations are never silent.

### V. Active COBOL Contract Beats Unused Artifacts
For current behavior, the active data contract is the code that actually runs:
the inline FD `ACCOUNT-REC` layouts in `INIT-DB.CBL`, `TRANS-PROC.CBL`, and
`REPORT-GEN.CBL`, plus the line-sequential `ACCOUNTS.DAT` file. `ACCOUNTS.CPY`
is not currently included by any active program and conflicts on balance storage
(`COMP-3` in the copybook vs display numeric fields in active programs). Any
target data model MUST reconcile this explicitly before implementation.

### VI. Incremental Migration Over Big Bang
Future target work is delivered in small, independently testable slices. Start
with a walking skeleton only after SDD approval, then migrate one workbook epic
or tightly-related scenario group at a time. No whole-system rewrite without
per-feature parity checkpoints.

### VII. Branch-First, Main-Stable Workflow
`main` stays the usable integration baseline. Work happens on scoped branches or
small direct documentation commits agreed by the owner. Keep unrelated refactors,
generated churn, and exploratory edits out of scoped changes.

### VIII. Explicit Data Mutation Control
The target system MUST NOT create, migrate, seed, or otherwise mutate data during
normal application startup. Schema changes, seed/reference data, and demo reset
actions are explicit operator/developer actions. This mirrors the legacy
distinction between starting the menu and explicitly choosing `Init Database`.

### IX. Automated Verification at the Lowest Useful Level
New or changed target behavior MUST ship automated tests. Use unit tests for pure
domain/validation/mapping logic and integration/contract tests for persistence,
API, serialization, and configuration boundaries. Tests that need real external
state are categorized. Any test deferral is documented in the spec/plan with a
follow-up task and rationale.

### X. Clean Code, No Magic Values
No magic strings or numbers in target code. Account statuses, transaction types,
account ids used as demo fixtures, config keys, file/table names, route names,
and error codes live as named constants/enums/typed options and are reused.

### XI. Modernization May Improve Unsafe Legacy Behavior
Where legacy behavior is unsafe or misleading, the target should improve it and
document the deviation. Examples: missing file crashes, `Saving...` after invalid
transaction type, unchecked shell-command return codes, no authentication, and no
audit trail. Security and operability improvements are expected, but they must be
traceable to workbook rows and SDD decisions.

### XII. Workbook-Driven Coverage Tracking
Each spec sets workbook SDD columns for its rows (`Covered in SDD?`,
`Deferred in SDD?`, and `SDD evidence`). Destination columns are filled at
implementation time. Row color follows:

- red: legacy behavior exists but target/SDD does not cover or defer it
- orange: covered/deferred/partial or an intentional decision is pending
- green: implemented with tests and parity or documented deviation holds

If tasks are generated, the corresponding `specs/NNN-*/tasks.md` checkboxes stay
in sync with workbook status.

## Technology Stack & Tooling

### Current legacy baseline
- **Language/runtime:** COBOL compiled with GnuCOBOL.
- **Entry point:** `BANK-MAIN.CBL`.
- **Modules:** `INIT-DB.CBL`, `TRANS-PROC.CBL`, `REPORT-GEN.CBL`.
- **Persistence:** line-sequential flat file `ACCOUNTS.DAT`.
- **Demo/deploy:** Docker Compose service `core-banking`.
- **Demo instruction:** `docs/cobol-demo.md`.
- **Legacy evidence workbook:** `analysis/legacy_user_flows.xlsx`.

### Target stack
The target modernization stack is **not selected yet**. Selecting .NET, Java,
Angular, SQL Server, PostgreSQL, or any other runtime/database is an
amendment-level decision. Once selected, this section must be updated before
implementation tasks are generated.

### SDD artifacts
Future SDD artifacts live under `specs/NNN-<slug>/`. This constitution lives at
`.specify/memory/constitution.md`.

## Development Workflow

- Follow `analysis/legacy_user_flows_template_instructions.md`:
  legacy evidence -> re-analysis -> SDD -> owner approval -> implementation ->
  parity verification -> SDD/workbook reconciliation.
- Keep the legacy terminal app runnable locally and on the demo server.
- Before implementation, write/update `spec.md`, clarify open questions, create
  `plan.md`, then `tasks.md`.
- Implement only after owner approval.
- Record important discoveries in docs/specs/workbook, not only in chat.

## Quality Gates

- `docker compose run --rm core-banking` opens the legacy menu.
- Scripted smoke flow passes:
  `Init Database -> Report -> Deposit -> Report -> Withdraw -> Report`.
- Workbook rows have concrete source evidence.
- SDD coverage is recorded before implementation.
- Target behavior has automated tests before rows are marked green.
- Explicit deviations are documented in the spec and workbook notes.
- No target startup auto-migration/auto-seeding/data mutation.

## Governance

If a spec conflicts with this constitution, the spec must be revised or must
propose an amendment with rationale and expected impact. Versioning is semantic:
MAJOR for principle removals/redefinitions, MINOR for new principles/sections,
PATCH for clarifications.

**Version**: 1.0.0 | **Ratified**: Pending | **Last Amended**: 2026-07-09

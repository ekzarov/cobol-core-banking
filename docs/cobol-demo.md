# COBOL Core Banking: legacy demo instruction

This document describes the first golden legacy flow only. It is intentionally
limited to the old COBOL terminal application, before Excel refinement, SDD, or
any modern implementation work.

The flow comes from `analysis/legacy_user_flows.xlsx`. Each step references the
legacy user-flow epic (`UF-*`) that should later be used as evidence for SDD.

| | Legacy COBOL |
|---|---|
| Server path | `/opt/cobol-core-banking` |
| Runtime | Docker Compose terminal session |
| Entry command | `docker compose run --rm core-banking` |
| UI | Console menu, no browser URL |
| Data file | `ACCOUNTS.DAT` inside the container working directory |

## Connect to the demo server

From Windows PowerShell:

```powershell
ssh -i $env:USERPROFILE\.ssh\xplanner_demo root@91.98.17.159
```

On the server:

```bash
cd /opt/cobol-core-banking
docker compose run --rm core-banking
```

You should see:

```text
=== CORE BANKING SYSTEM ===
1. Init Database
2. Transaction
3. Report
4. Exit
Option:
```

## PART A - LEGACY COBOL terminal flow

### A1. Start menu - UF-001 Console Menu & Program Dispatch

Confirm that the menu shows four operations:

```text
1. Init Database
2. Transaction
3. Report
4. Exit
```

This is the whole legacy UI. There is no web page, login, navigation bar, or
mouse-driven screen.

### A2. Initialize demo account file - UF-002 Account Database Initialization

At `Option:` enter:

```text
1
```

Expected result:

```text
Database initialized.
```

Meaning: the program rewrites `ACCOUNTS.DAT` with three known active accounts:

| Account | Name | Balance |
|---|---|---:|
| `1000000001` | `JOHN DOE` | `$5,000.00` |
| `1000000002` | `JANE SMITH` | `$12,500.50` |
| `1000000003` | `BOB JOHNSON` | `$100.00` |

### A3. Print initial report - UF-004 Account Balance Reporting

At `Option:` enter:

```text
3
```

Expected result:

```text
TOTAL ACCOUNTS: 00003
BANK BALANCE: $        17,600.50
```

Also confirm the report lists the three accounts above.

### A4. Deposit money - UF-003 Account Transaction Processing

At `Option:` enter:

```text
2
```

Then enter:

```text
Account Number: 1000000001
Type (D/W): D
Amount: 250.00
```

Expected result:

```text
Deposit Ok.
Saving...
```

### A5. Confirm deposit in report - UF-004 Account Balance Reporting

At `Option:` enter:

```text
3
```

Expected result:

```text
1000000001
JOHN DOE
$         5,250.00

BANK BALANCE: $        17,850.50
```

### A6. Withdraw money - UF-003 Account Transaction Processing

At `Option:` enter:

```text
2
```

Then enter:

```text
Account Number: 1000000001
Type (D/W): W
Amount: 100
```

Expected result:

```text
Withdrawal Ok.
Saving...
```

### A7. Confirm withdrawal in report - UF-004 Account Balance Reporting

At `Option:` enter:

```text
3
```

Expected result:

```text
1000000001
JOHN DOE
$         5,150.00

BANK BALANCE: $        17,750.50
```

### A8. Invalid menu option - UF-001 Console Menu & Program Dispatch

At `Option:` enter any unsupported value, for example:

```text
9
```

Expected result:

```text
Invalid.
```

The menu should continue running.

### A9. Invalid transaction type - UF-003 Account Transaction Processing

At `Option:` enter:

```text
2
```

Then enter:

```text
Account Number: 1000000001
Type (D/W): X
Amount: 10
```

Expected result:

```text
Invalid Type.
Saving...
```

Important legacy detail: the account is still found, so the program rewrites the
file, but the balance remains unchanged.

### A10. Unknown account - UF-003 Account Transaction Processing

At `Option:` enter:

```text
2
```

Then enter:

```text
Account Number: 9999999999
Type (D/W): D
Amount: 10
```

Expected result:

```text
Not Found.
```

### A11. Insufficient funds - UF-003 Account Transaction Processing

At `Option:` enter:

```text
2
```

Then enter:

```text
Account Number: 1000000003
Type (D/W): W
Amount: 1000
```

Expected result:

```text
No Funds.
Saving...
```

The account remains at `$100.00`.

### A12. Exit - UF-001 Console Menu & Program Dispatch

At `Option:` enter:

```text
4
```

Expected result:

```text
Bye.
```

The container exits and returns to the server shell.

## Fast scripted smoke check

If you only need to verify the main happy path without typing the menu:

```bash
cd /opt/cobol-core-banking
printf '1\n3\n2\n1000000001\nD\n250.00\n3\n2\n1000000001\nW\n100\n3\n4\n' | docker compose run --rm -T core-banking ./BANK-MAIN
```

Expected balances:

```text
Initial BANK BALANCE: 17,600.50
After deposit:        17,850.50
After withdrawal:     17,750.50
```

## Legacy observations to mention

- This is a terminal program, not a web application.
- The "database" is a flat file: `ACCOUNTS.DAT`.
- Account updates use a classic sequential-file pattern: write all records to
  `ACCOUNTS.TMP`, then replace `ACCOUNTS.DAT`.
- The copybook defines account statuses `A`, `C`, and `S`, but the current
  runtime flow only seeds `A` and does not enforce status-specific behavior.
- There is no authentication, authorization, audit trail, API, browser UI, or
  relational database.

## Checklist before moving to Excel / SDD

- [ ] Server SSH works.
- [ ] `cd /opt/cobol-core-banking` works.
- [ ] `docker compose run --rm core-banking` opens the menu.
- [ ] Init Database creates the three accounts.
- [ ] Report shows total balance `$17,600.50`.
- [ ] Deposit `250.00` into `1000000001` changes total to `$17,850.50`.
- [ ] Withdraw `100` from `1000000001` changes total to `$17,750.50`.
- [ ] Invalid menu option shows `Invalid.`.
- [ ] Unknown account shows `Not Found.`.
- [ ] Insufficient funds shows `No Funds.`.

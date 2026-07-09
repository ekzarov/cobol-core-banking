# Core Banking COBOL Demo

This folder is a local deployment spike for the public
`fzn0x/core-banking-system` COBOL sample.

## Run

Build the container:

```powershell
docker compose build
```

Start the interactive COBOL menu:

```powershell
docker compose run --rm core-banking
```

Useful demo flow:

1. Choose `1` to initialize `ACCOUNTS.DAT`.
2. Choose `3` to print the balance report.
3. Choose `2`, account `1000000001`, type `D`, amount `250.00`.
4. Choose `3` again and confirm the changed balance.
5. Choose `4` to exit.

## Notes

- The original sample used Windows shell commands for replacing
  `ACCOUNTS.DAT`. For Docker/Linux, this spike uses `rm` and `mv`.
- Called COBOL programs return to the menu with `GOBACK`.
- This is intentionally a console legacy baseline, not a modernized UI/API.

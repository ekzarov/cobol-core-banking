# Core Banking System (COBOL)

This is a demonstration of a simplified Core Banking System implemented in COBOL.

## Components
- `ACCOUNTS.CPY`: Data structure for account records.
- `INIT-DB.CBL`: Initializes the `ACCOUNTS.DAT` file with sample data.
- `TRANS-PROC.CBL`: Handles deposits and withdrawals.
- `REPORT-GEN.CBL`: Generates a balance summary report.
- `BANK-MAIN.CBL`: Main menu driver for the system.

## How to Run

### Prerequisites
- **GnuCOBOL (OpenCOBOL)**: You need `cobc` installed and in your PATH.
  - Windows: [GnuCOBOL for Windows](https://www.arnoldtrembley.com/GnuCOBOL.htm) or use [msys2](https://www.msys2.org/)
  - Linux: `sudo apt-get install gnucobol`

### Installation on Windows

Install on MSYS2 MINGW64: 

```powershell
pacman -Sy
pacman -S mingw-w64-x86_64-gnucobol
cobc --version
```

### Installation on Linux

```powershell
sudo apt-get install gnucobol
```

### Compilation & Execution
Since COBOL programs often call each other, you should compile them as modules or dynamic libraries.

```powershell
# Set environment variables (Windows)
$env:COB_CONFIG_DIR = "C:\msys64\mingw64\share\gnucobol\config"
$env:COB_COPY_DIR = "C:\msys64\mingw64\share\gnucobol\copy"

# Compile all modules
cobc -m INIT-DB.CBL
cobc -m TRANS-PROC.CBL
cobc -m REPORT-GEN.CBL
cobc -x BANK-MAIN.CBL

# Run the main program
./BANK-MAIN
```

## Features
1. **Database Initialization**: Resets the `ACCOUNTS.DAT` file to a known state.
2. **Transaction Processing**: Supports real-time updates for deposits and withdrawals.
3. **Reporting**: Provides a formatted summary of all accounts and total bank balance.

## Note on File Handling
In this simplified version, the transaction processor uses a temporary file (`ACCOUNTS.TMP`) to perform updates and simulate a sequential record update process typical in batch COBOL environments.

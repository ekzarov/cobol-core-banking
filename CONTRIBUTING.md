# Contributing to Core Banking System

Thank you for your interest in contributing to the Core Banking System COBOL project!

## How to Contribute

### Reporting Bugs
If you find a bug, please create an issue with a detailed description of the problem and steps to reproduce it.

### Feature Requests
We welcome feature requests! Please create an issue to discuss your ideas.

### Pull Requests
1. Fork the repository.
2. Create a new branch for your changes.
3. Ensure your COBOL code follows the existing style (72-column limit, proper division structure).
4. Include a newline at the end of all `.CBL` and `.CPY` files.
5. Submit a pull request with a clear description of your changes.

## Development Environment
- **Compiler**: GnuCOBOL (`cobc`)
- **System**: Windows (MSYS2/MinGW-w64 recommended)

## Coding Standards
- Use `LINE SEQUENTIAL` for data files where appropriate.
- Maintain clear `WORKING-STORAGE` organization.
- Ensure all programs have proper `IDENTIFICATION DIVISION`.

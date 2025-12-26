# Git Push Fix Documentation

## Root Cause

Some files and directories contained emojis, Polish diacritic characters, or spaces in their names or content. This caused issues with git push, cross-platform compatibility, and automation tools.

## Solution

- All emojis, Polish diacritic characters, and spaces were removed from filenames, directory names, and key configuration values.
- All references in documentation and scripts were updated to use only ASCII characters and underscores or hyphens.
- .gitignore was added with standard patterns for node_modules, build outputs, IDE files, logs, and temporary files.

## Filename Convention

- Use only ASCII characters (A-Z, a-z, 0-9, _, -).
- Do not use spaces, emojis, or diacritic characters in filenames or directory names.
- Use underscores or hyphens to separate words.

## Example

**Bad:**

    Klucze szyfrowania.txt
    bezpieczenstwo/klucze.txt
    my file.md

**Good:**

    encryption_keys.txt
    security/keys.txt
    my_file.md

## Additional Notes

- All scripts and documentation should follow this convention for future compatibility and automation reliability.
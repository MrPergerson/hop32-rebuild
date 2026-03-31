# CLAUDE.md

Primary project: hop32-rebuild

# Running and Testing

- Launch a cartridge: open PICO-8 and type `load <cartname>` then `run`, or run from command line with `pico8 -run carts/<cartname>.p8`
- PICO-8 has no external build system, linter, or test framework. Testing is done by running the cartridge in PICO-8.
- Export for web: in PICO-8, `export <name>.html` produces an HTML+JS bundle
- Debug output: use `printh(msg)` which writes to the PICO-8 console/log

# Rules
Always assume the working directory is the primary project unless stated otherwise
Never create files without asking first

## PICO-8 Code Limits

- **Tokens:** Max 8,192 tokens. A token is a variable, operator, opening bracket, or keyword (except `end` and `local`). Commas, semicolons, closing brackets, `end`, `local`, and comments are free.
- **Characters:** Max 65,535 uncompressed characters across all code (including `#include`d files).
- **Compressed size:** Max 15,360 bytes compressed — required for saving as `.p8.png` or exporting to binary. Not enforced for `.p8` format.
- **`#include` files:** Included `.lua` files count toward the same character and token limits as inline code. There is no separate per-file limit, but if the included file pushes total chars over 65,535 you will get a "file too long" error.
- **Token-saving tips:** Combine assignments (`a,b=1,2`), use dot access over bracket access (`t.x` vs `t["x"]`), pack repeated data into strings and `split()` at runtime.
- In practice, **tokens dominate** — you will almost always hit the token limit before the character limit unless you are packing large data as strings.

# Boundaries


# Skills

## run a Pico-8 cart
If you see "run [file_name].p8" then follow these steps
1. Always use powershell. Do not use bash
2. cd to the working directory if you haven't already. 
3. Run this command in this format "./[file_name].p8"







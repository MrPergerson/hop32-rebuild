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

# Boundaries


# Skills

## run a Pico-8 cart
If you see "run [file_name].p8" then follow these steps
1. Always use powershell. Do not use bash
2. cd to the working directory if you haven't already. 
3. Run this command in this format "./[file_name].p8"







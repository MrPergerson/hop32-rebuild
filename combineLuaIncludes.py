import sys
import os
import re

def main():
    if len(sys.argv) != 3:
        print("Usage: python combineLuaIncludes.py <input.p8> <output.lua>")
        sys.exit(1)

    p8_path = sys.argv[1]
    output_path = sys.argv[2]

    if not os.path.isfile(p8_path):
        print(f"Error: '{p8_path}' not found")
        sys.exit(1)

    p8_dir = os.path.dirname(os.path.abspath(p8_path))

    with open(p8_path, "r") as f:
        lines = f.readlines()

    # Find #include lines in the __lua__ section
    in_lua_section = False
    includes = []
    for line in lines:
        stripped = line.strip()
        if stripped == "__lua__":
            in_lua_section = True
            continue
        if in_lua_section and re.match(r"^__\w+__$", stripped):
            break
        if in_lua_section:
            match = re.match(r"^#include\s+(.+\.lua)\s*$", stripped)
            if match:
                includes.append(match.group(1))

    if not includes:
        print("No #include directives found in __lua__ section")
        sys.exit(1)

    # Read and combine all included files
    combined = []
    for filename in includes:
        filepath = os.path.join(p8_dir, filename)
        if not os.path.isfile(filepath):
            print(f"Error: included file '{filename}' not found at {filepath}")
            sys.exit(1)
        with open(filepath, "r") as f:
            content = f.read()
        combined.append(f"-- === {filename} ===\n{content}")

    # Write combined output
    output = "\n".join(combined)
    with open(output_path, "w") as f:
        f.write(output)

    print(f"Combined {len(includes)} files into '{output_path}':")
    for name in includes:
        print(f"  - {name}")

if __name__ == "__main__":
    main()

import sys
import os
import re
import subprocess

def combine_lua(p8_path):
    p8_dir = os.path.dirname(os.path.abspath(p8_path))
    with open(p8_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    in_lua = False
    includes = []
    for line in lines:
        stripped = line.strip()
        if stripped == "__lua__":
            in_lua = True
            continue
        if in_lua and re.match(r"^__\w+__$", stripped):
            break
        if in_lua:
            m = re.match(r"^#include\s+(.+\.lua)\s*$", stripped)
            if m:
                includes.append(m.group(1))

    if not includes:
        print("Error: no #include directives found in __lua__ section")
        sys.exit(1)

    parts = []
    for filename in includes:
        filepath = os.path.join(p8_dir, filename)
        if not os.path.isfile(filepath):
            print(f"Error: included file not found: {filepath}")
            sys.exit(1)
        with open(filepath, "r", encoding="utf-8") as f:
            parts.append(f.read())

    print(f"  Combined {len(includes)} files")
    return "\n".join(parts)

def inject_lua(p8_path, lua_content, output_path):
    with open(p8_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    result = []
    in_lua = False
    for line in lines:
        stripped = line.strip()
        if stripped == "__lua__":
            in_lua = True
            result.append(line)
            result.append(lua_content)
            if not lua_content.endswith("\n"):
                result.append("\n")
            continue
        if in_lua and re.match(r"^__\w+__$", stripped):
            in_lua = False
        if not in_lua:
            result.append(line)

    out_dir = os.path.dirname(os.path.abspath(output_path))
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(result)

def parse_token_count(text):
    m = re.search(r"tokens:\s*(\d+)", text)
    return m.group(1) if m else None

def main():
    if len(sys.argv) < 3:
        print("Usage: python build.py <input.p8> <output.p8> [--minify]")
        sys.exit(1)

    p8_path = os.path.abspath(sys.argv[1])
    output_path = os.path.abspath(sys.argv[2])
    aggressive = "--minify" in sys.argv

    script_dir = os.path.dirname(os.path.abspath(__file__))
    shrinko8 = os.path.join(script_dir, "shrinko8", "shrinko8.py")

    if not os.path.isfile(p8_path):
        print(f"Error: input file not found: {p8_path}")
        sys.exit(1)
    if not os.path.isfile(shrinko8):
        print(f"Error: shrinko8 not found at {shrinko8}")
        sys.exit(1)

    out_dir = os.path.dirname(output_path)
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)

    combined_path = os.path.join(out_dir or ".", "combined.lua")
    combined_min_path = os.path.join(out_dir or ".", "combined_min.lua")

    # Step 1: Combine
    print("Step 1: Combining lua files...")
    combined = combine_lua(p8_path)
    with open(combined_path, "w", encoding="utf-8") as f:
        f.write(combined)

    # Step 2: Minify
    minify_flag = "--minify" if aggressive else "--minify-safe-only"
    print(f"Step 2: Minifying ({minify_flag} --focus-tokens)...")
    cmd = [
        sys.executable, shrinko8,
        combined_path, combined_min_path,
        minify_flag, "--focus-tokens",
        "--count", "--input-count"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if result.returncode != 0:
        print("Error: minification failed")
        print(result.stderr)
        sys.exit(1)

    # Step 3: Inject into .p8
    print("Step 3: Building output cart...")
    with open(combined_min_path, "r", encoding="utf-8") as f:
        minified = f.read()
    inject_lua(p8_path, minified, output_path)

    # Report
    output = result.stdout + result.stderr
    lines = [l for l in output.splitlines() if l.strip()]
    print("\nToken counts:")
    for line in lines:
        print(f"  {line}")
    print(f"\nOutput: {output_path}")

if __name__ == "__main__":
    main()

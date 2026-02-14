import sys
import os
import re
import shlex
import subprocess

def main():
    if len(sys.argv) < 3:
        print("Usage: python minifyBatch.py <path-to-.p8-file> <minify-options>")
        print('Example: python minifyBatch.py hop32.p8 "--minify-safe-only"')
        sys.exit(1)

    p8_path = os.path.abspath(sys.argv[1])
    minify_options = shlex.split(sys.argv[2])
    base_dir = os.path.dirname(p8_path)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    shrinko8_path = os.path.join(script_dir, "shrinko8", "shrinko8.py")
    export_dir = os.path.join(base_dir, "minifyBatchExport")

    if not os.path.isfile(p8_path):
        print(f"Error: {p8_path} not found")
        sys.exit(1)

    if not os.path.isfile(shrinko8_path):
        print(f"Error: shrinko8 not found at {shrinko8_path}")
        sys.exit(1)

    # Parse #include directives from the .p8 file
    includes = []
    with open(p8_path, "r") as f:
        for line in f:
            match = re.match(r"^#include\s+(.+\.lua)\s*$", line)
            if match:
                includes.append(match.group(1))

    if not includes:
        print("No #include directives found in the .p8 file.")
        sys.exit(0)

    print(f"Found {len(includes)} included lua files.")

    os.makedirs(export_dir, exist_ok=True)

    success = 0
    failed = 0
    for lua_file in includes:
        input_path = os.path.join(base_dir, lua_file)
        output_path = os.path.join(export_dir, lua_file)

        if not os.path.isfile(input_path):
            print(f"  SKIP {lua_file} (file not found)")
            failed += 1
            continue

        cmd = [sys.executable, shrinko8_path, input_path, output_path] + minify_options
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print(f"  OK   {lua_file}")
            success += 1
        else:
            print(f"  FAIL {lua_file}")
            if result.stderr:
                print(f"       {result.stderr.strip()}")
            failed += 1

    print(f"\nDone: {success} succeeded, {failed} failed")
    print(f"Output: {export_dir}")

if __name__ == "__main__":
    main()

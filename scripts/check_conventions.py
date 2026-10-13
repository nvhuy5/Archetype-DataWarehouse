"""Model conventions (see NAMING.vi.md), read from the dbt manifest.
Run after `dbt parse`: python3 scripts/check_conventions.py target/manifest.json"""
import json
import re
import sys

manifest = json.load(open(sys.argv[1]))
KEY_TESTS = {"unique", "not_null", "unique_combination_of_columns"}
errors = []

for node_id, node in manifest["nodes"].items():
    if node["resource_type"] != "model" or node["package_name"] != "archetype":
        continue
    name, path, code = node["name"], node["original_file_path"], node.get("raw_code", "")

    # names by layer
    if "/staging/" in path:
        source = path.split("/staging/")[1].split("/")[0]
        if not name.startswith(f"stg_{source}__"):
            errors.append(f"{name}: staging model must be named stg_{source}__<table>")
    elif "/dwh/intermediate/" in path:
        if not name.startswith("int_"):
            errors.append(f"{name}: intermediate model must start with int_")
    elif "/dwh/" in path:
        if not re.match(r"(dim|fact)_", name):
            errors.append(f"{name}: dwh model must start with dim_ or fact_")
    elif "/mart/" in path:
        if not name.startswith("mart_"):
            errors.append(f"{name}: mart model must start with mart_")
    else:
        errors.append(f"{name}: model outside staging, dwh or mart ({path})")

    # documented
    description = (node.get("description") or "").strip()
    if not description:
        errors.append(f"{name}: missing description")

    # tested key (a staging table without a primary key must say so)
    tests = {
        (manifest["nodes"].get(child, {}).get("test_metadata") or {}).get("name")
        for child in manifest["child_map"].get(node_id, [])
    }
    if not tests & KEY_TESTS and "No primary key" not in description:
        errors.append(f"{name}: no key test (unique/not_null) and the description does not say 'No primary key'")

    # no select * (column drift in the source must not pass silently)
    if re.search(r"select\s+(distinct(\s+on\s*\([^)]*\))?\s+)?\*|[\w\"]\.\*", code, re.I):
        errors.append(f"{name}: uses select *; list the columns")

if errors:
    print("\n".join(sorted(errors)))
    sys.exit(1)
print("OK: conventions respected")

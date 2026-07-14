#!/usr/bin/env bash

set -uo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
godot_bin="${GODOT_BIN:-godot}"
tests=()

if ! command -v "$godot_bin" >/dev/null 2>&1; then
	echo "Godot executable not found: $godot_bin" >&2
	exit 2
fi

if (($# > 0)); then
	tests=("$@")
else
	while IFS= read -r test_path; do
		tests+=("$test_path")
	done < <(find "$project_root/scripts/tests" -maxdepth 1 -type f \( -name '*_test.gd' -o -name '*_smoke_test.gd' \) | sort)
fi

failed=0
passed=0

for test_path in "${tests[@]}"; do
	if [[ "$test_path" = /* ]]; then
		absolute_test_path="$test_path"
	else
		absolute_test_path="$project_root/${test_path#res://}"
	fi
	resource_path="res://${absolute_test_path#"$project_root/"}"
	log_path="$(mktemp "${TMPDIR:-/tmp}/gama-stock-test.XXXXXX")"

	set +e
	"$godot_bin" --headless --path "$project_root" --script "$resource_path" >"$log_path" 2>&1
	exit_code=$?
	set -e

	if ((exit_code != 0)) || grep -Eq '(^|[[:space:]])(SCRIPT ERROR:|USER ERROR:|ERROR:|FATAL:)' "$log_path"; then
		echo "FAIL $resource_path"
		cat "$log_path"
		failed=$((failed + 1))
	else
		echo "PASS $resource_path"
		passed=$((passed + 1))
	fi
	rm -f "$log_path"
done

echo "Test summary: $passed passed, $failed failed"
if ((failed > 0)); then
	exit 1
fi

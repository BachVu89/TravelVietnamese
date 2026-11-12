#!/usr/bin/env bash
# Run every GDScript test suite headlessly and report per-suite status.
set -uo pipefail
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/godot-data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/godot-config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/godot-cache}"
GODOT="${GODOT:-$HOME/tools/godot/Godot_v4.6.3-stable_linux.x86_64}"
cd "$(dirname "${BASH_SOURCE[0]}")/../game3d" || exit 2
fail=0
for f in tests/test_*.gd; do
  out=$(timeout 120 "$GODOT" --headless --path . -s "res://$f" 2>&1)
  code=$?
  [ $code -ne 0 ] && fail=1
  echo "$f exit=$code :: $(echo "$out" | grep -E '^RESULT|SCRIPT ERROR|Parse Error|FAIL:' | head -4)"
done
echo "OVERALL_FAIL=$fail"
exit $fail

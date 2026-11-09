#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "$0")/.." && pwd)"
dotnet_bin="${DOTNET_BIN:-/workspace/dotnet/dotnet}"
if [[ ! -x "$dotnet_bin" ]]; then echo 'BLOCKED: .NET SDK missing; no test ran.' >&2; exit 2; fi
export DOTNET_CLI_HOME="${TMPDIR:-/tmp}/viettrail-dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
"$dotnet_bin" run --project "$root_dir/Tests/CoreTests.csproj" --configuration Release

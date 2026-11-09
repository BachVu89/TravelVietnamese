#!/usr/bin/env bash
set -euo pipefail
root_dir="$(cd "$(dirname "$0")/.." && pwd)"
export DOTNET_CLI_HOME="${TMPDIR:-/tmp}/viettrail-dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
"${DOTNET_BIN:-/workspace/dotnet/dotnet}" run --project "$root_dir/Tests/Syntax/Syntax.csproj" --configuration Release -- "$root_dir/Assets"

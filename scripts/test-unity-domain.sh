#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dotnet_exe="${DOTNET_BIN:-/workspace/dotnet/dotnet}"
if [[ ! -x "$dotnet_exe" ]]; then
  dotnet_exe="$(command -v dotnet || true)"
fi
if [[ -z "$dotnet_exe" || ! -x "$dotnet_exe" ]]; then
  echo 'BLOCKED: .NET SDK unavailable; no domain test executed.' >&2
  exit 2
fi
export DOTNET_CLI_HOME="${TMPDIR:-/tmp}/travelvietnamese-dotnet-cli"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
"$dotnet_exe" run --project "$repo_root/unity/TravelVietnamese/Tests/DomainHarness.csproj" --configuration Release

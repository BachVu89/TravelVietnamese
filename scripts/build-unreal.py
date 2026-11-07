#!/usr/bin/env python3
"""Explicit UE5 editor/Android build entrypoint; never downloads engine or assets."""
import argparse
import json
from pathlib import Path
import platform
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'unreal/TravelVietnamese/TravelVietnamese.uproject'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine', required=True, type=Path,
                        help='UE installation root containing Engine/Build/Build.version')
    parser.add_argument('--target', choices=['editor', 'android'], default='editor')
    parser.add_argument('--output', type=Path, default=ROOT / 'artifacts/unreal-android')
    parser.add_argument('--check-only', action='store_true',
                        help='Check prerequisites only; does not compile or cook')
    args = parser.parse_args()
    engine = args.engine.expanduser().resolve()
    version_path = engine / 'Engine/Build/Build.version'
    if not version_path.is_file():
        parser.exit(2, f'BLOCKED: UE installation not found: {version_path}\n'
                    'Install a licensed UE5 editor/toolchain first; no build was run.\n')
    version = json.loads(version_path.read_text(encoding='utf-8-sig'))
    major, minor = version.get('MajorVersion'), version.get('MinorVersion')
    if major != 5 or not isinstance(minor, int) or minor < 5:
        parser.exit(2, 'BLOCKED: This source scaffold targets UE 5.5 or newer UE5; '
                    'review API/plugin compatibility on upgrades.\n')
    if not PROJECT.is_file():
        parser.exit(2, f'BLOCKED: Missing project: {PROJECT}\n')
    host = platform.system()
    if host not in ('Linux', 'Darwin', 'Windows'):
        parser.exit(2, f'BLOCKED: Unsupported build host: {host}\n')
    batch = engine / 'Engine/Build/BatchFiles'
    if args.target == 'editor':
        folder, filename, ue_host = {
            'Linux': ('Linux', 'Build.sh', 'Linux'),
            'Darwin': ('Mac', 'Build.sh', 'Mac'),
            'Windows': ('', 'Build.bat', 'Win64'),
        }[host]
        entry = batch / folder / filename
        command = [str(entry), 'TravelVietnameseEditor', ue_host, 'Development',
                   str(PROJECT), '-WaitMutex']
    else:
        preview_map = PROJECT.parent / 'Content/Maps/PassPreview.umap'
        if not preview_map.is_file():
            parser.exit(2, 'BLOCKED: Generate and save PassPreview in the compiled UE editor first.\n'
                        'No Android cook was run; source-only scaffolding has no .umap.\n')
        entry = batch / ('RunUAT.bat' if host == 'Windows' else 'RunUAT.sh')
        command = [str(entry), 'BuildCookRun', f'-project={PROJECT}', '-noP4',
                   '-platform=Android', '-cookflavor=ASTC',
                   '-clientconfig=Development', '-build', '-cook', '-stage',
                   '-pak', '-archive', f'-archivedirectory={args.output.resolve()}']
    if not entry.is_file():
        parser.exit(2, f'BLOCKED: Missing UE build entrypoint: {entry}\n')
    print(f'UE {major}.{minor}: {args.target} build entrypoint found.', flush=True)
    if args.check_only:
        print('CHECK ONLY: SDK, compilation, plugins, materials, map and device support remain unverified.')
        return 0
    if host == 'Windows':
        command = ['cmd.exe', '/d', '/c'] + command
    print('Starting Unreal toolchain; success is determined by its exit code, not this preflight.', flush=True)
    return subprocess.run(command, cwd=PROJECT.parent, check=False).returncode


if __name__ == '__main__':
    sys.exit(main())

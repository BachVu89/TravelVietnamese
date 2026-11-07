#!/usr/bin/env python3
"""Invoke a user-provided, licensed Unity Editor; does not install/activate Unity."""
import argparse
import subprocess
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / 'unity/TravelVietnamese'

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--editor',type=Path,required=True,help='Unity executable from the pinned Editor installation')
    p.add_argument('--profile',choices=['mobile','hdrp'],default='mobile')
    p.add_argument('--target',choices=['scene','android'],default='scene')
    p.add_argument('--check-only',action='store_true')
    a=p.parse_args()
    project=PROJECT if a.profile=='mobile' else ROOT/'unity/TravelVietnamese-HDRP'
    if a.profile=='hdrp' and a.target=='android':p.exit(2,'BLOCKED: HDRP is a desktop reference, not an Android build profile.\n')
    editor=a.editor.expanduser().resolve()
    if not editor.is_file():p.exit(2,f'BLOCKED: Unity Editor executable missing: {editor}\nNo Unity compile/build ran.\n')
    if not (project/'ProjectSettings/ProjectVersion.txt').is_file():p.exit(2,'BLOCKED: Unity project pin missing.\n')
    if a.check_only:
        print('Entrypoint exists only; version, activation/license, packages, modules, compile and devices unverified.')
        return 0
    method=('PassProjectSetup.CreateMobilePass' if a.profile=='mobile' else 'DesktopPassSetup.CreateDesktopPass') if a.target=='scene' else 'PassProjectSetup.BuildAndroid'
    command=[str(editor),'-batchmode','-nographics','-quit','-projectPath',str(project),
             '-executeMethod','TravelVietnamese.Editor.'+method,'-logFile','-']
    if a.target=='android':command+=['-buildTarget','Android']
    return subprocess.run(command,cwd=project,check=False).returncode

if __name__=='__main__':sys.exit(main())

#!/usr/bin/env python3
"""Verify the packaged Godot trial and its honest geography coverage metadata."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import subprocess
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('apk', type=Path)
parser.add_argument('--sdk', type=Path, default=Path('/workspace/android-sdk'))
parser.add_argument('--previous-apk', type=Path, help='Also verify the signing identity and versionCode permit an update')
args = parser.parse_args()
apk = args.apk.resolve(strict=True)
with zipfile.ZipFile(apk) as archive:
    assert archive.testzip() is None, 'Corrupt APK archive'
    files = set(archive.namelist())
    for required in ['assets/project.binary', 'assets/scripts/main.gdc', 'assets/scripts/player.gdc', 'assets/data/geography/LICENSE-vietnamese-provinces-database.txt']:
        assert required in files, f'Missing offline resource: {required}'
    for abi in ['arm64-v8a', 'armeabi-v7a']:
        assert f'lib/{abi}/libgodot_android.so' in files, f'Missing {abi} engine'
    assert not any('/tests/' in name or '/qa/' in name for name in files), 'QA scripts should not ship'
    regions = json.loads(archive.read('assets/data/geography/regions.json'))
    metadata = json.loads(archive.read('assets/data/geography/sources.json'))
    assert len(regions) == 47 and len({r['id'] for r in regions}) == 47
    assert sum(r['type'] == 'province' for r in regions) == 34
    assert sum(r['type'] == 'island' for r in regions) == 13
    assert metadata['coverage']['all_vietnam_islands_verified'] is False

tools = sorted((args.sdk / 'build-tools').glob('*'))[-1]
subprocess.run([str(tools / 'apksigner'), 'verify', '--verbose', str(apk)], check=True)
subprocess.run([str(tools / 'zipalign'), '-c', '-P', '16', '4', str(apk)], check=True)
badging = subprocess.check_output([str(tools / 'aapt'), 'dump', 'badging', str(apk)], text=True)
assert "package: name='com.travelvietnamese.docmienviet3d'" in badging
assert 'application-debuggable' not in badging
if args.previous_apk:
    previous = args.previous_apk.resolve(strict=True)
    def signer_digest(path):
        details = subprocess.check_output([str(tools / 'apksigner'), 'verify', '--print-certs', str(path)], text=True)
        match = re.search(r'Signer #1 certificate SHA-256 digest: ([0-9a-f]+)', details)
        assert match, 'Cannot identify signing certificate'
        return match.group(1)
    old_badging = subprocess.check_output([str(tools / 'aapt'), 'dump', 'badging', str(previous)], text=True)
    assert "package: name='com.travelvietnamese.docmienviet3d'" in old_badging
    assert signer_digest(previous) == signer_digest(apk), 'Update uses a different signing certificate'
    current_code = int(re.search(r"versionCode='(\d+)'", badging).group(1))
    previous_code = int(re.search(r"versionCode='(\d+)'", old_badging).group(1))
    assert current_code > previous_code, 'Update must have a higher versionCode'
    print('Update identity verified: same package/certificate, versionCode', previous_code, '->', current_code)
permissions = subprocess.check_output([str(tools / 'aapt'), 'dump', 'permissions', str(apk)], text=True)
assert "name='android.permission.INTERNET'" not in permissions
for line in badging.splitlines():
    if line.startswith(('package:', 'sdkVersion:', 'targetSdkVersion:', 'native-code:', 'uses-gl-es:', 'application-label:')):
        print(line)
with apk.open('rb') as stream:
    print('SHA256:', hashlib.file_digest(stream, 'sha256').hexdigest())
print('Size:', apk.stat().st_size, 'bytes')
print('PASS: signed release, alignment, offline Godot resources, 34 provinces + 13 island areas, MIT license, no INTERNET permission')

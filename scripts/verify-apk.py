#!/usr/bin/env python3
"""Verify a standalone trial APK using the installed Android build tools."""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('apk', type=Path)
parser.add_argument('--sdk', type=Path, default=Path(os.environ.get('ANDROID_HOME', '/workspace/android-sdk')))
args = parser.parse_args()
apk = args.apk.resolve(strict=True)
with zipfile.ZipFile(apk) as archive:
    assert archive.testzip() is None, 'APK ZIP integrity check failed'
    names = archive.namelist()
    assert 'AndroidManifest.xml' in names, 'Missing manifest'
    assert any(n.endswith('.dex') for n in names), 'Missing Android bytecode'
    bundles = [n for n in names if n.startswith('assets/') and n.endswith('.bundle')]
    assert bundles and all(archive.getinfo(n).file_size > 100_000 for n in bundles), 'Missing embedded game bundle'
    abis = sorted({n.split('/')[1] for n in names if n.startswith('lib/') and n.endswith('.so')})
    assert 'arm64-v8a' in abis, 'Missing ARM64 support'
    print('Embedded bundle:', ', '.join(bundles))
    print('Native architectures:', ', '.join(abis))

tools = sorted((args.sdk / 'build-tools').glob('*'))
assert tools, 'Android SDK build-tools required for signature/manifest checks'
build_tools = tools[-1]
subprocess.run([str(build_tools / 'apksigner'), 'verify', '--verbose', str(apk)], check=True)
badging = subprocess.run([str(build_tools / 'aapt'), 'dump', 'badging', str(apk)], check=True, capture_output=True, text=True).stdout
assert "package: name='com.travelvietnamese.docmienviet'" in badging, 'Unexpected application ID'
assert 'application-debuggable' not in badging, 'Expected non-debuggable release variant'
for line in badging.splitlines():
    if line.startswith(('package:', 'sdkVersion:', 'targetSdkVersion:', 'application-label:', 'native-code:', 'launchable-activity:')):
        print(line)
print('Size:', apk.stat().st_size, 'bytes')
with apk.open('rb') as stream:
    print('SHA256:', hashlib.file_digest(stream, 'sha256').hexdigest())
print('PASS: APK structure, embedded game bundle, ARM64, signature, package and release manifest')

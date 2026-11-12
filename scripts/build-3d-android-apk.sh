#!/usr/bin/env bash
# Standalone offline trial APK. Signing material stays outside the repository.
set -euo pipefail
project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_dir"
app_version=$(python3 - <<'PYVERSION'
import pathlib,re
print(re.search(r'^version/name="([^"]+)"$', pathlib.Path('game3d/export_presets.cfg').read_text(), re.M).group(1))
PYVERSION
)
artifact_stem="doc-mien-viet-3d-$app_version"
GODOT_BIN="${GODOT_BIN:-/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-/workspace/godot-data}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-/workspace/godot-config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/workspace/godot-cache}"
export ANDROID_HOME="${ANDROID_HOME:-/workspace/android-sdk}"
export JAVA_HOME="${TRAVEL_JDK17_HOME:-/workspace/java/jdk-17.0.17+10}"
build_tools="$ANDROID_HOME/build-tools/36.0.0"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME/godot" "$XDG_CACHE_HOME" artifacts
python3 - <<'PY'
import os,pathlib,re
p=pathlib.Path(os.environ['XDG_CONFIG_HOME'])/'godot/editor_settings-4.6.tres'
s=p.read_text() if p.exists() else '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n'
for key,value in [('export/android/android_sdk_path',os.environ['ANDROID_HOME']),('export/android/java_sdk_path',os.environ['JAVA_HOME'])]:
 s=re.sub(r'^'+re.escape(key)+r'\s*=.*\n?', '', s, flags=re.M)
 s+='\n'+key+' = "'+value.replace('\\','\\\\').replace('"','\\"')+'"\n'
p.write_text(s)
PY
"$GODOT_BIN" --headless --path game3d --editor --quit
"$GODOT_BIN" --headless --path game3d --export-release Android ../artifacts/${artifact_stem}-unsigned.apk
signing_dir="$XDG_CONFIG_HOME/godot/trial-signing"
mkdir -p "$signing_dir"
chmod 700 "$signing_dir"
if [[ ! -f "$signing_dir/store.password" ]]; then
  python3 - "$signing_dir/store.password" <<'PY'
import pathlib,secrets,sys,os
p=pathlib.Path(sys.argv[1]);p.write_text(secrets.token_hex(24)+'\n');os.chmod(p,0o600)
PY
fi
if [[ ! -f "$signing_dir/trial.keystore" ]]; then
  "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$signing_dir/trial.keystore" \
    -storetype JKS -alias travel-trial -keyalg RSA -keysize 2048 -validity 3650 \
    -storepass:file "$signing_dir/store.password" -keypass:file "$signing_dir/store.password" \
    -dname 'CN=Doc Mien Viet Trial, O=Local Development, C=VN' >/dev/null 2>&1
  chmod 600 "$signing_dir/trial.keystore"
fi
"$build_tools/zipalign" -f -P 16 4 artifacts/${artifact_stem}-unsigned.apk artifacts/${artifact_stem}-aligned.apk
"$build_tools/apksigner" sign --ks "$signing_dir/trial.keystore" --ks-key-alias travel-trial \
  --ks-pass "file:$signing_dir/store.password" \
  --out artifacts/${artifact_stem}.apk artifacts/${artifact_stem}-aligned.apk
"$build_tools/apksigner" verify --verbose artifacts/${artifact_stem}.apk
"$build_tools/zipalign" -c -P 16 4 artifacts/${artifact_stem}.apk
sha256sum artifacts/${artifact_stem}.apk > artifacts/${artifact_stem}.apk.sha256
rm artifacts/${artifact_stem}-unsigned.apk artifacts/${artifact_stem}-aligned.apk
printf 'Standalone trial APK: %s/artifacts/%s.apk\n' "$project_dir" "$artifact_stem"

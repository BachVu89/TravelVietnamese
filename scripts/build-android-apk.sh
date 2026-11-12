#!/usr/bin/env bash
# Test distribution only: release bundle signed with the generated Android debug key.
set -euo pipefail
project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_dir"
: "${ANDROID_HOME:=/workspace/android-sdk}"
export ANDROID_HOME
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-/workspace/.gradle}"
export EXPO_OFFLINE=1
export NODE_ENV=production
TRAVEL_JDK17_HOME="${TRAVEL_JDK17_HOME:-/workspace/java/jdk-17.0.17+10}"
if [[ ! -x "$TRAVEL_JDK17_HOME/bin/javac" ]]; then
  echo "Set TRAVEL_JDK17_HOME to an installed JDK 17." >&2
  exit 1
fi
export JAVA_HOME="$TRAVEL_JDK17_HOME"
# Reuse managed CA trust for the downloaded JDK; do not disable TLS checks.
java_trust_args=""
if [[ -f /etc/ssl/certs/java/cacerts ]]; then
  java_trust_args="-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts"
  export GRADLE_OPTS="${GRADLE_OPTS:-} $java_trust_args"
fi
if [[ ! -d node_modules ]]; then npm ci; fi
if [[ ! -f android/gradlew ]]; then npx expo prebuild --platform android --no-install; fi
# Java/Gradle do not automatically consume HTTPS_PROXY. Preserve TLS verification.
if [[ -n "${HTTPS_PROXY:-}" ]]; then
  proxy_java_args=$(node -e 'const p=new URL(process.env.HTTPS_PROXY); console.log(`-Dhttps.proxyHost=${p.hostname} -Dhttps.proxyPort=${p.port||80} -Dhttp.proxyHost=${p.hostname} -Dhttp.proxyPort=${p.port||80}`)')
  export GRADLE_OPTS="${GRADLE_OPTS:-} $proxy_java_args"
fi
cd android
./gradlew :app:assembleRelease --no-daemon --max-workers=3 \
  -Dorg.gradle.jvmargs="-Xmx4096m -XX:MaxMetaspaceSize=1024m $java_trust_args" \
  -Porg.gradle.java.installations.paths="$TRAVEL_JDK17_HOME" \
  -Porg.gradle.java.installations.auto-download=false
cd "$project_dir"
mkdir -p artifacts
cp android/app/build/outputs/apk/release/app-release.apk artifacts/doc-mien-viet-0.1.0.apk
sha256sum artifacts/doc-mien-viet-0.1.0.apk > artifacts/doc-mien-viet-0.1.0.apk.sha256
printf 'APK: %s/artifacts/doc-mien-viet-0.1.0.apk\n' "$project_dir"

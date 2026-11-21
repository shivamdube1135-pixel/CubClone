#!/usr/bin/env bash
# 构建 cubclone.jar（无需 gradle）
set -eu
cd "$(dirname "${BASH_SOURCE[0]}")"

SDK="${ANDROID_HOME:-D:/Dev/Android/Sdk}"
AJ="$SDK/platforms/android-36/android.jar"
JAVA="${JAVA_HOME:-D:/Dev/Java/Env/jdk-21.0.12.1+1}"
BT="$SDK/build-tools/35.0.0"
PY="${PYTHON:-python}"

[ -f "$AJ" ] || { echo "找不到 android.jar: $AJ"; exit 1; }
[ -f "$BT/d8.bat" ] || [ -f "$BT/d8" ] || { echo "找不到 d8: $BT"; exit 1; }

rm -rf classes dexout cubclone.jar
mkdir -p classes dexout

echo "[1/3] javac"
"$JAVA/bin/javac.exe" -J-Dfile.encoding=UTF-8 -source 8 -target 8 -nowarn \
  -cp "$AJ" -d classes CubClone.java

echo "[2/3] d8"
if [ -f "$BT/d8.bat" ]; then D8="$BT/d8.bat"; else D8="$BT/d8"; fi
"$D8" --lib "$AJ" --min-api 26 --output dexout classes/*.class

echo "[3/3] jar"
"$PY" -c "
import zipfile
with zipfile.ZipFile('cubclone.jar','w',zipfile.ZIP_DEFLATED) as z:
    z.write('dexout/classes.dex','classes.dex')
"
ls -lh cubclone.jar
echo "OK"

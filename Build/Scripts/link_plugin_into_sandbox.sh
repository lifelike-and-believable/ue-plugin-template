#!/usr/bin/env bash
set -e
PLUGIN_PATH="$(pwd)/Plugins/SamplePlugin"
SANDBOX_PATH="$(pwd)/ProjectSandbox"
DST="${SANDBOX_PATH}/Plugins/SamplePlugin"
rm -rf "$DST"
mkdir -p "$(dirname "$DST")"
ln -s "$PLUGIN_PATH" "$DST"
echo "Linked: $DST -> $PLUGIN_PATH"

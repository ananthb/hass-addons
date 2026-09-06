#!/usr/bin/env bash
# ==============================================================================
# Globalping add-on: map add-on options onto the environment the probe
# reads, then hand off to the upstream entrypoint unchanged.
# ==============================================================================
set -e

OPTIONS=/data/options.json

# No bashio here: this container is the upstream probe image, not a Home
# Assistant base image. jq is already installed -- the probe's own
# entrypoint uses it for the self-update check -- so options are read
# with that instead.
token=$(jq -r '.adoption_token // empty' "${OPTIONS}")

if [ -n "${token}" ]; then
    export GP_ADOPTION_TOKEN="${token}"
    echo "[globalping] Adoption token set; the probe will adopt itself."
else
    echo "[globalping] No adoption token set. The probe will still run and"
    echo "[globalping] serve measurements, it just will not be linked to a"
    echo "[globalping] Globalping account or earn credits. Get a token at"
    echo "[globalping] https://dash.globalping.io and set it in the add-on"
    echo "[globalping] configuration."
fi

# /entrypoint.sh checks for a newer probe release, replaces /app if it
# finds one, and then execs node. Calling it rather than reimplementing
# it keeps the self-update working across upstream changes.
exec /bin/bash /entrypoint.sh

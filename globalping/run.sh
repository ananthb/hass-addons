#!/usr/bin/env bash
# ==============================================================================
# Globalping add-on: give the probe a durable identity, map add-on options
# onto the environment it reads, then hand off to the upstream entrypoint.
# ==============================================================================
set -e

OPTIONS=/data/options.json
UUID_FILE=/data/probe-uuid

# The probe's identity has to outlive the container. Upstream keeps it in
# /.globalping-probe-uuid -- the root of the image's writable layer, which
# the Supervisor discards whenever the add-on is rebuilt -- so every update
# produced a new UUID and an adopted probe fell out of its account:
#
#   No persistent UUID file. Generating a new one.
#   Starting probe version 0.52.0 ... with UUID 89aafdd2
#
# GP_PROBE_UUID is upstream's own answer to this: setPersistentUUID()
# returns early when it is set, for "persistence on read-only systems with
# firmware support". So this fights none of the probe's logic, it just
# keeps the identity in /data, the one directory that survives.
if [ ! -s "${UUID_FILE}" ]; then
    if [ -r /proc/sys/kernel/random/uuid ]; then
        cat /proc/sys/kernel/random/uuid > "${UUID_FILE}"
    else
        node -e 'process.stdout.write(require("node:crypto").randomUUID())' > "${UUID_FILE}"
    fi
    echo "[globalping] Generated a new probe UUID."
fi

GP_PROBE_UUID=$(tr -d '[:space:]' < "${UUID_FILE}")
export GP_PROBE_UUID
echo "[globalping] Probe UUID ${GP_PROBE_UUID:0:8} (kept in /data, survives updates)"

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

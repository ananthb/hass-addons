#!/usr/bin/with-contenv bashio
# ==============================================================================
# airsupply add-on: turn add-on options into environment and start the
# diagnostic. Nothing here is logged except the version line; the PIN in
# particular goes into the environment and nowhere else.
# ==============================================================================
set -e

if ! bashio::fs.socket_exists /run/dbus/system_bus_socket; then
    bashio::log.fatal "No D-Bus system socket at /run/dbus/system_bus_socket."
    bashio::log.fatal "The add-on needs host_dbus, which config.yaml sets; something upstream is off."
    bashio::exit.nok
fi

export AIRSUPPLY_LOG_LEVEL="$(bashio::config 'log_level')"
export AIRSUPPLY_ADDRESS="$(bashio::config 'address')"
export AIRSUPPLY_CONNECT="$(bashio::config 'connect')"
export AIRSUPPLY_READ="$(bashio::config 'read')"
# bashio::config prints the value on stdout, so this assignment is the only
# place the PIN appears.
export AIRSUPPLY_PIN="$(bashio::config 'pin')"

bashio::log.info "airsupply ${AIRSUPPLY_VERSION:-dev} starting."

exec python3 -m airsupply

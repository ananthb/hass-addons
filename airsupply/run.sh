#!/usr/bin/with-contenv bashio
# ==============================================================================
# airsupply add-on: turn add-on options into environment and start the page.
# ==============================================================================
set -e

if ! bashio::fs.socket_exists /run/dbus/system_bus_socket; then
    bashio::log.fatal "No D-Bus system socket at /run/dbus/system_bus_socket."
    bashio::log.fatal "The add-on needs host_dbus, which config.yaml sets; something upstream is off."
    bashio::exit.nok
fi

export AIRSUPPLY_LOG_LEVEL="$(bashio::config 'log_level')"
export AIRSUPPLY_PORT=8099

bashio::log.info "airsupply ${AIRSUPPLY_VERSION:-dev} starting; open it from the sidebar."

exec python3 -m airsupply

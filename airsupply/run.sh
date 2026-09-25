#!/usr/bin/with-contenv bashio
# ==============================================================================
# airsupply add-on: turn add-on options and Supervisor services into
# environment, then start the page.
# ==============================================================================
set -e

if ! bashio::fs.socket_exists /run/dbus/system_bus_socket; then
    bashio::log.fatal "No D-Bus system socket at /run/dbus/system_bus_socket."
    bashio::log.fatal "The add-on needs host_dbus, which config.yaml sets; something upstream is off."
    bashio::exit.nok
fi

export AIRSUPPLY_LOG_LEVEL="$(bashio::config 'log_level')"
export AIRSUPPLY_PORT=8099
export AIRSUPPLY_READ_EVERY="$(( $(bashio::config 'read_every_minutes') * 60 ))"

# The broker, if there is one. `mqtt:want` means the Supervisor hands these
# over when the Mosquitto add-on is installed and says nothing when it is not,
# so there is no broker to configure and no credential to keep anywhere.
if bashio::services.available "mqtt"; then
    export AIRSUPPLY_MQTT_HOST="$(bashio::services 'mqtt' 'host')"
    export AIRSUPPLY_MQTT_PORT="$(bashio::services 'mqtt' 'port')"
    export AIRSUPPLY_MQTT_USERNAME="$(bashio::services 'mqtt' 'username')"
    export AIRSUPPLY_MQTT_PASSWORD="$(bashio::services 'mqtt' 'password')"
    bashio::log.info "Publishing to the MQTT broker at ${AIRSUPPLY_MQTT_HOST}:${AIRSUPPLY_MQTT_PORT}."
else
    bashio::log.warning "No MQTT service. The page works and the machine can be read,"
    bashio::log.warning "but nothing will appear in Home Assistant. Install the Mosquitto add-on."
fi

if ! bashio::var.has_value "${SUPERVISOR_TOKEN:-}"; then
    bashio::log.warning "No Supervisor token; Home Assistant's people cannot be listed."
fi

bashio::log.info "airsupply ${AIRSUPPLY_VERSION:-dev} starting; reading every $(bashio::config 'read_every_minutes') minutes."

exec python3 -m airsupply

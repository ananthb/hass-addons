# BUILD_FROM is the upstream airsupply image, pinned in build.yaml. It is
# built on the Home Assistant base, so s6-overlay and bashio are already in
# it. Everything this add-on adds is the options bridge: the Supervisor
# writes the user's settings to /data/options.json, and airsupply reads
# AIRSUPPLY_* from the environment.
ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

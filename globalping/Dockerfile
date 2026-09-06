# BUILD_FROM is the upstream probe image, pinned per architecture in
# build.yaml. Everything this add-on adds is the options bridge: the
# Supervisor writes the user's settings to /data/options.json, and the
# probe reads GP_ADOPTION_TOKEN from the environment.
ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Same shape as the image we are extending: tini reaps, then a bash
# script sets up and execs the probe. run.sh hands off to the upstream
# entrypoint, so the self-update path is untouched.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD [ "/bin/bash", "/run.sh" ]

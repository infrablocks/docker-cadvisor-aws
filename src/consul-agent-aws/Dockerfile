ARG BASE_IMAGE_VERSION
FROM infrablocks/consul-aws:$BASE_IMAGE_VERSION

COPY docker-entrypoint.sh /consul/bin/agent-docker-entrypoint.sh

ENV STARTUP_SCRIPT_PATH=/consul/bin/agent-docker-entrypoint.sh

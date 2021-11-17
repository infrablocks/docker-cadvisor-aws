#!/bin/bash

[ "$TRACE" = "yes" ] && set -x
set -e

CADVISOR_LOGGING_OPTIONS="${CADVISOR_LOGGING_OPTIONS:- --logtostderr}"

CADVISOR_PORT_OPTION=
if [ -n "$CADVISOR_PORT" ]; then
  CADVISOR_PORT_OPTION="--port=${CADVISOR_PORT}"
  echo "==> Found request to listen on port '${CADVISOR_PORT}', setting port option..."
fi

HOUSEKEEPING_INTERVAL_OPTION=
if [ -n "$HOUSEKEEPING_INTERVAL" ]; then
  HOUSEKEEPING_INTERVAL_OPTION="--housekeeping_interval=${HOUSEKEEPING_INTERVAL}"
  echo "==> Found request to set housekeeping interval '${HOUSEKEEPING_INTERVAL}', setting interval option..."
fi

DISABLE_METRICS_OPTION=
if [ -n "$DISABLE_METRICS" ]; then
  DISABLE_METRICS_OPTION="--disable_metrics=${DISABLE_METRICS}"
  echo "==> Found request to disable metrics '${DISABLE_METRICS}', setting disable metrics option..."
fi

DOCKER_ONLY_OPTION=
if [ -n "$DOCKER_ONLY" ]; then
  DOCKER_ONLY_OPTION="--docker_only=${DOCKER_ONLY}"
  echo "==> Found request for docker metrics only '${DOCKER_ONLY}', setting docker only option..."
fi

exec /opt/cadvisor/bin/cadvisor \
    ${CADVISOR_LOGGING_OPTIONS} \
    ${CADVISOR_PORT_OPTION} \
    ${HOUSEKEEPING_INTERVAL_OPTION} \
    ${DISABLE_METRICS_OPTION} \
    ${DOCKER_ONLY_OPTION}

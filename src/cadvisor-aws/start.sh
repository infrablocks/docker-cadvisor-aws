#!/bin/bash

[ "$TRACE" = "yes" ] && set -x
set -e

CADVISOR_LOGGING_OPTIONS="${CADVISOR_LOGGING_OPTIONS:- --logtostderr}"

CADVISOR_PORT_OPTION=
if [ -n "$CADVISOR_PORT" ]; then
  CADVISOR_PORT_OPTION="--port=${CADVISOR_PORT}"
  echo "==> Found request to listen on port '${CADVISOR_PORT}', setting port option..."
fi

CADVISOR_HOUSEKEEPING_INTERVAL_OPTION=
if [ -n "$CADVISOR_HOUSEKEEPING_INTERVAL" ]; then
  CADVISOR_HOUSEKEEPING_INTERVAL_OPTION="--housekeeping_interval=${CADVISOR_HOUSEKEEPING_INTERVAL}"
  echo "==> Found request to set housekeeping interval '${CADVISOR_HOUSEKEEPING_INTERVAL}', setting interval option..."
fi

CADVISOR_DISABLE_METRICS_OPTION=
if [ -n "$CADVISOR_DISABLE_METRICS" ]; then
  CADVISOR_DISABLE_METRICS_OPTION="--disable_metrics=${CADVISOR_DISABLE_METRICS}"
  echo "==> Found request to disable metrics '${CADVISOR_DISABLE_METRICS}', setting disable metrics option..."
fi

CADVISOR_DOCKER_ONLY_OPTION=
if [ -n "$CADVISOR_DOCKER_ONLY" ]; then
  CADVISOR_DOCKER_ONLY_OPTION="--docker_only=${CADVISOR_DOCKER_ONLY}"
  echo "==> Found request for docker metrics only '${CADVISOR_DOCKER_ONLY}', setting docker only option..."
fi

exec /opt/cadvisor/bin/cadvisor \
    ${CADVISOR_LOGGING_OPTIONS} \
    ${CADVISOR_PORT_OPTION} \
    ${CADVISOR_HOUSEKEEPING_INTERVAL_OPTION} \
    ${CADVISOR_DISABLE_METRICS_OPTION} \
    ${CADVISOR_DOCKER_ONLY_OPTION}

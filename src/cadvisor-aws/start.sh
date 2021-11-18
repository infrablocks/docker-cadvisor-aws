#!/bin/bash

[ "$TRACE" = "yes" ] && set -x
set -e

logging_options="${CADVISOR_LOGGING_OPTIONS:- --logtostderr}"

port_option=
if [ -n "$CADVISOR_PORT" ]; then
  port_option="--port=${CADVISOR_PORT}"
  echo "==> Found request to listen on port '${CADVISOR_PORT}', setting port option..."
fi

housekeeping_interval_option=
if [ -n "$CADVISOR_HOUSEKEEPING_INTERVAL" ]; then
  housekeeping_interval_option="--housekeeping_interval=${CADVISOR_HOUSEKEEPING_INTERVAL}"
  echo "==> Found request to set housekeeping interval '${CADVISOR_HOUSEKEEPING_INTERVAL}', setting interval option..."
fi

disable_metrics_option=
if [ -n "$CADVISOR_DISABLE_METRICS" ]; then
  disable_metrics_option="--disable_metrics=${CADVISOR_DISABLE_METRICS}"
  echo "==> Found request to disable metrics '${CADVISOR_DISABLE_METRICS}', setting disable metrics option..."
fi

docker_only_option=
if [ -n "$CADVISOR_DOCKER_ONLY_ENABLED" ]; then
  if [[ "$CADVISOR_DOCKER_ONLY_ENABLED" = "yes" ]]; then
    echo "==> Found request to expose only docker cgroups, setting docker only option to 'true'..."
    docker_only_option="--docker_only=true"
  else
    echo "==> Found request to expose all cgroups, setting docker only option to 'false'..."
    docker_only_option="--docker_only=false"
  fi
fi

echo "Running cadvisor."
# shellcheck disable=SC2086
exec /opt/cadvisor/bin/cadvisor \
    ${logging_options} \
    ${port_option} \
    ${housekeeping_interval_option} \
    ${disable_metrics_option} \
    ${docker_only_option}

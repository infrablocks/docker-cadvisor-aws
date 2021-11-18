#!/bin/bash

[ "$TRACE" = "yes" ] && set -x
set -e

logging_options="${CADVISOR_LOGGING_OPTIONS}"

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

logtostderr_option="--logtostderr=true"
if [ -n "$CADVISOR_LOGTOSTDERR_ENABLED" ]; then
  if [[ "$CADVISOR_LOGTOSTDERR_ENABLED" = "yes" ]]; then
    echo "==> Found request to log to stderr, setting logtostderr option to 'true'..."
    logtostderr_option="--logtostderr=true"
  else
    echo "==> Found request not to log to stderr, setting logtostderr option to 'false'..."
    logtostderr_option="--logtostderr=false"
  fi
fi


echo "Running cadvisor."
# shellcheck disable=SC2086
exec /opt/cadvisor/bin/cadvisor \
    ${logging_options} \
    ${logtostderr_option} \
    ${port_option} \
    ${housekeeping_interval_option} \
    ${disable_metrics_option} \
    ${docker_only_option}

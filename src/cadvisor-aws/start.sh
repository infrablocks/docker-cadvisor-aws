#!/bin/bash

[ "$TRACE" = "yes" ] && set -x
set -e

CADVISOR_LOGGING_OPTIONS="${CADVISOR_LOGGING_OPTIONS:- --logtostderr}"

CADVISOR_PORT_OPTION=
if [ -n "$CADVISOR_PORT" ]; then
  CADVISOR_PORT_OPTION="--port=${CADVISOR_PORT}"
  echo "==> Found request to listen on port '${CADVISOR_PORT}', setting port option..."
fi

exec /opt/cadvisor/bin/cadvisor \
    ${CADVISOR_LOGGING_OPTIONS} \
    ${CADVISOR_PORT_OPTION}

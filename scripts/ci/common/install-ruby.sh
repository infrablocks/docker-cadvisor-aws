#!/usr/bin/env bash

[ -n "$DEBUG" ] && set -x
set -e
set -o pipefail

apk --update add \
    bash \
    ca-certificates \
    ruby \
    ruby-bundler

echo 'gem: --no-document' > /etc/gemrc

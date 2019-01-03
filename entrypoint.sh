#!/bin/sh

set -e
set -x

if [ ! "$1" ]; then
    exec /concourse/workers-cleaner.sh
fi

exec "$@"

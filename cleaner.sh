#!/bin/sh

set -e

# Check that we provided all env variables
if [ -z $CONCOURSE_URL ]; then
    echo "CONCOURSE_URL must be specified. Example: https://concourse.foo.io"
    exit 1
elif [ -z $CONCOURSE_ADMIN_USERNAME ]; then
    echo "CONCOURSE_ADMIN_USERNAME must be specified. Example: admin"
    exit 1
elif [ -z $CONCOURSE_ADMIN_PASSWORD ]; then
    echo "CONCOURSE_ADMIN_PASSWORD must be specified. Example: secret"
    exit 1
fi

# Set default value for optional env variables
if [ -z $CONCOURSE_TARGET ]; then
    export CONCOURSE_TARGET=admin
fi
if [ -z $CONCOURSE_TEAM ]; then
    export CONCOURSE_TEAM=main
fi
if [ -z $PRUNE_TIME ]; then
    export PRUNE_TIME=3600
fi

mkdir -p bin

echo "### $(date) Starting on target $CONCOURSE_TARGET (team $CONCOURSE_TEAM) with PRUNE_TIME $PRUNE_TIME secondes ..."

while true; do

curl -s -L https://github.com/concourse/concourse/releases/latest | egrep -o '/concourse/concourse/releases/download/[0-9]*/concourse_linux_amd64' | wget --base=http://github.com/ -i - -O concourse



    # Get fly each time in case concourse version changed between 2 clean
    echo "... Get fly from ${CONCOURSE_URL}"
    wget -q -O bin/fly "${CONCOURSE_URL}/api/v1/cli?arch=amd64&platform=linux"
    wget https://github.com/concourse/concourse/releases/download/latest/fly_linux_amd64
    chmod +x bin/fly

    # Login into concourse
    echo "... Login as ${CONCOURSE_ADMIN_USERNAME}"
    fly -t ${CONCOURSE_TARGET} login -n ${CONCOURSE_TEAM} --concourse-url=${CONCOURSE_URL} --username=${CONCOURSE_ADMIN_USERNAME} --password=${CONCOURSE_ADMIN_PASSWORD}

    echo "... prune stalled workers"
    if [ $CONCOURSE_TEAM != "main" ]; then
        # grep on the team name to avoid concurrent prune on shared workers
        for WORKER in $(fly -t ${CONCOURSE_TARGET} workers | grep stalled | grep $CONCOURSE_TEAM | cut -d' '  -f1); do fly -t ${CONCOURSE_TARGET} prune-worker -w $WORKER; done
    else
        for WORKER in $(fly -t ${CONCOURSE_TARGET} workers | grep stalled | cut -d' '  -f1); do fly -t ${CONCOURSE_TARGET} prune-worker -w $WORKER; done
    fi

    echo "### $(date) Done, sleeping for the next clean"
    sleep $PRUNE_TIME
done


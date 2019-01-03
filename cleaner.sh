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

mkdir -p bin

echo "### $(date) Starting on target $CONCOURSE_TARGET (team $CONCOURSE_TEAM) with PRUNE_TIME $PRUNE_TIME secondes ..."

# Login into concourse
echo "... Login as ${CONCOURSE_ADMIN_USERNAME}"
fly -t ${CONCOURSE_TARGET} login -n ${CONCOURSE_TEAM} --concourse-url=${CONCOURSE_URL} --username=${CONCOURSE_ADMIN_USERNAME} --password=${CONCOURSE_ADMIN_PASSWORD}

echo "... prune stalled workers"
if [ $CONCOURSE_TEAM != "main" ]; then
	# grep on the team name to avoid concurrent prune on shared workers
	for WORKER in $(fly -t ${CONCOURSE_TARGET} workers | grep stalled | grep $CONCOURSE_TEAM | cut -d' ' -f1); do fly -t ${CONCOURSE_TARGET} prune-worker -w $WORKER; done
else
	for WORKER in $(fly -t ${CONCOURSE_TARGET} workers | grep stalled | cut -d' ' -f1); do fly -t ${CONCOURSE_TARGET} prune-worker -w $WORKER; done
fi

echo "### $(date) Done."

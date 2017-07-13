#!/bin/bash

set -x
set -e

cmd=( mvn clean test )

if [ -n "$MAXSCALE_VERSION" ]
then
    #maxscale version is set
    echo "$MAXSCALE_VERSION"
else
    #default version
    export MAXSCALE_VERSION=2.1.4
fi

docker-compose -f .travis/docker-compose.yml build
docker-compose -f .travis/docker-compose.yml up -d

mysql=( mysql --protocol=tcp -ubob -h127.0.0.1 --port=4007 )

for i in {30..0}; do
    if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
        break
    fi
    echo 'maxscale still not active'
    sleep 1
done

docker-compose -f .travis/docker-compose.yml logs

if [ "$i" = 0 ]; then
    echo 'SELECT 1' | "${mysql[@]}"
    echo >&2 'Maxscale init process failed.'
    exit 1
fi


###################################################################################################################
# run test suite
###################################################################################################################
echo "Running coveralls for JDK version: $TRAVIS_JDK_VERSION"

"${cmd[@]}"
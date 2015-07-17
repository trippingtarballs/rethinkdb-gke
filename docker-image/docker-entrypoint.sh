#!/bin/bash
set -eo pipefail

export RETHINKDB_JOIN_ARGS

url="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/${POD_NAMESPACE:-default}/endpoints"
cert="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
header="Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
pod_ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

setArgs () {
    if [[ -n "${KUBERNETES_SERVICE_HOST}" ]]; then
        service="${1}"

        echo "Checking running ${service} ..."

        echo "curl: $(curl -s "${url}/${service}" --cacert "${cert}" --header "${header}")"
        RETHINKDB_JOIN_ARGS=($(curl -s "${url}/${service}" --cacert "${cert}" --header "${header}" | jq -s -r --arg h "${pod_ip}" '.[0].subsets | .[].addresses | "--join " + .[].ip + ":29015"'))

        echo "RETHINKDB_JOIN_ARGS:" "${RETHINKDB_JOIN_ARGS[@]}"
    fi
}

if [ "$1" = 'rethinkdb' ]; then
    if [[ "${RETHINKDB_INSTANCE_ROLE}" = 'PROXY' ]]; then
        echo "Adding a PROXY node."

        # find all db-nodes and use their IPs with proxy command to rethinkdb
        setArgs "db-nodes"

        echo rethinkdb proxy "${RETHINKDB_JOIN_ARGS[@]}" --bind all
        exec rethinkdb proxy "${RETHINKDB_JOIN_ARGS[@]}" --bind all
    fi

    if [[ "${RETHINKDB_INSTANCE_ROLE}" = 'NODE' ]]; then
        echo "Adding a NODE node."

        # find all db-proxies –> either first time node, or cluster growing
        setArgs "db-proxies"

        if [ ${#RETHINKDB_INSTANCE_ROLE[@]} -eq 0 ]; then
            exec rethinkdb --bind all
        fi
        echo "inside .. RETHINKDB_JOIN_ARGS:" "${RETHINKDB_JOIN_ARGS[@]}"
        exec rethinkdb "${RETHINKDB_JOIN_ARGS[@]}" --bind all
    fi
fi

exec "$@"

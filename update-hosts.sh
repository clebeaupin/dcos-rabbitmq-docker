#!/bin/bash

set -e

TASK_LIST_URL="$1/v2/apps/$2/tasks"
HOST_FILE_PATH="$3"

buildHostBlock()
{
    local taskListContent=$(curl -s $TASK_LIST_URL)

    for task in $(echo "${taskListContent}" | jq -r '.tasks[] | @base64'); do
        _jq() {
            echo ${task} | base64 -d | jq -r ${1}
        }

        local hostIp=$(_jq '.ipAddresses[0].ipAddress')

        if [ "$hostIp" != "null" ]
        then
            local hostName=$(_jq '.id')
            hostBlock="${hostBlock}${hostIp} ${hostName}\n"
        fi
    done
}

updateHostFile()
{
    local start="### START - DYNAMIC MARATHON HOSTS"
    local end="### END - DYNAMIC MARATHON HOSTS"

    tmpFilePath=$(mktemp /tmp/host.XXXXXX)
    cp $HOST_FILE_PATH $tmpFilePath
    sed -i "/$start/,/$end/c\
$start\n$hostBlock\n$end" $tmpFilePath
    cat $tmpFilePath > $HOST_FILE_PATH
    rm $tmpFilePath
}

echo -e "### START - DYNAMIC MARATHON HOSTS\n`hostname -i` $APP_SHORTNAME\n### END - DYNAMIC MARATHON HOSTS\n" >> $HOST_FILE_PATH

# while true
# do
	# hostBlock="\n"
    # buildHostBlock
    # updateHostFile
    # cat $HOST_FILE_PATH

    # Update every 30 seconds
	# sleep 30
# done


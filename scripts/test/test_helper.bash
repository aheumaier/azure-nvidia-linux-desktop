# bats helpers.bash

docker_mock(){
    local command=$1
    local parameters="${@:2}"
    echo "Calling docker_mock with ${command} ${parameters}"
    docker exec -i -e DEBIAN_FRONTEND=noninteractive "${DOCKER_SUT_ID}" bash -c "${command} ${parameters}"
    return $?
}

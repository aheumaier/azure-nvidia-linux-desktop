#!/usr/bin/env bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'test_helper'

profile_script="./scripts/setup_ubuntu_desktop.sh"

setup() {
    DOCKER_SUT_ID=$(docker run -d ubuntu:18.04)
}

function teardown() {
    docker stop $DOCKER_SUT_ID && docker rm $DOCKER_SUT_ID
}

@test "test install_system_packages() should install provided packes" {
    # skip
    source ${profile_script}
    function sudo() { docker_mock "${*}";  }
    export -f sudo 
    declare -ar PACKAGES=( wget curl gnupg2 x11vnc libusb-0.1-4 libxvidcore4 libaa1 libfaad2 libxss1 libopencore-amrnb0 libopencore-amrwb0 )
    run install_system_packages
    assert_success

}
@test "test install_nvidia_repos() should install nvidia_repos" {
    # skip
    NVIDIA_PKG="nvidia-diag-driver-local-repo-ubuntu1804-415.25_1.0-1_amd64.deb"
    NVIDIA_REPO="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64"
    TMP_DIR="/tmp"
    source ${profile_script}
    function sudo() { docker_mock "${*}";  }
    export -f sudo 
    function wget() { docker_mock "wget" "${*}";  }
    export -f wget
    declare -ar PACKAGES=( wget curl gnupg2 )
    run install_system_packages 
    run install_nvidia_repos
    assert_success

}
@test "test install_cuda_repos() should install cuda_repos" {
    # skip
    CUDA_PKG="cuda-repo-ubuntu1804_10.0.130-1_amd64.deb"
    NVIDIA_REPO="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64"
    TMP_DIR="/tmp"
    source ${profile_script}
    function sudo() { docker_mock "${*}";  }
    export -f sudo 
    function wget() { docker_mock "wget" "${*}";  }
    export -f wget
    declare -ar PACKAGES=( wget curl gnupg2 )
    run install_system_packages 
    run install_cuda_repos
    assert_success

}
@test "test setup_x11vnc() should be properly configured" {
    skip
    VNC_PASS=$(openssl rand -base64 12)
    TMP_DIR="/tmp"
    source ${profile_script}
    function systemctl() { echo "This is running ${*}";  }
    export -f systemctl
    function sudo() { docker_mock "${*}";  }
    export -f sudo 
    declare -ar PACKAGES=( wget curl gnupg2 x11vnc )
    run install_system_packages 
    run setup_x11vnc
    assert_success
    run cat /etc/x11vnc.passwd
    assert_output ${VNC_PASS}
}

@test "test run_main should fail on missin env var" {
#   skip
    NVIDIA_PKG="nvidia-diag-driver-local-repo-ubuntu1804-415.25_1.0-1_amd64.deb"
    NVIDIA_REPO="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64"
    CUDA_PKG="cuda-repo-ubuntu1804_10.0.130-1_amd64.deb"
    USER_DEVSTACK=$(openssl rand -base64 12)
    unset PASS_DEVSTACK
    source ${profile_script}
    run run_main
    assert_failure 
    assert_output "Empty required env var found: var var_name. ABORT"
}
@test "test run_main should be successfull" {
#   skip
    source ${profile_script}
    VNC_PASS=$(openssl rand -base64 12)
    NVIDIA_PKG="nvidia-diag-driver-local-repo-ubuntu1804-415.25_1.0-1_amd64.deb"
    NVIDIA_REPO="http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64"
    CUDA_PKG="cuda-repo-ubuntu1804_10.0.130-1_amd64.deb"
    LD_LIBRARY_PATH="/usr/local/lib"
    function install_nvidia_repos() { echo "This would install_nvidia_repos ${*}"; }
    export -f install_nvidia_repos
    function install_cuda_repos() { echo "This would install_cuda_repos ${*}"; }
    export -f install_cuda_repos
    function install_system_packages() { echo "This would install_system_packages ${*}"; }
    export -f install_system_packages
    function install_nvidia_drivers() { echo "This would install_nvidia_drivers ${*}"; }
    export -f install_nvidia_drivers
    function setup_x11vnc() { echo "This would setup_x11vnc ${*}"; }
    export -f setup_x11vnc
    run run_main
    assert_success
}

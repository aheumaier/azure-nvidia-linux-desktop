#!/bin/bash
#
#  Perparing the linux system for  operating
#  simulation VTD components
#
#   Usage: sudo ./setup_ubuntu_desktop.sh
#
#
# === Break on the first Error ===
set -exo pipefail

if [ "${DEBUG}" ]; then
    set -o xtrace # Similar to -v, but expands commands, same as "set -x"
fi

# === Cleanup actions ===
function finish() {
    sudo /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
    rm -rf "$TMP_DIR"
}
# === Enforce clean-up on any circumstances ===
# trap finish EXIT

# === Installing Packages ===
install_system_packages() {
    sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"
}

# === Adding NVIDIA CUDA repositories ===
install_nvidia_repos() {
    sudo wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /"
}

# === Installing Cuda driver ===
install_nvidia_drivers() {
    sudo apt-get update
    sudo apt-get -y install cuda
    sudo nvidia-xconfig --use-display-device=none --virtual="3140x2160" # We will need it later for x11vnc
}

# === Configure x11vnc environment ===
setup_x11vnc() {
    sudo tee "/etc/systemd/system/x11vnc.service" >/dev/null <<'EOF'
[Unit]
Description=x11vnc VNC Server for X11
Requires=display-manager.service
After=display-manager.service

[Service]
Type=forking
ExecStartPre=/bin/bash -c "/bin/systemctl set-environment SDDMXAUTH=$(/usr/bin/find /var/run/sddm/ -type f)"
ExecStart=/usr/bin/x11vnc -display :0 -auth ${SDDMXAUTH} -forever -shared -bg -o /var/log/x11vnc.log -rfbauth /etc/x11vnc.passwd -xkb -norc -noxrecord -noxdamage -nomodtweak
ExecStop=/usr/bin/killall x11vnc
Restart=on-failure
RestartSec=2

[Install]
WantedBy=graphical.target

EOF
    sudo x11vnc -storepasswd $(hostname) /etc/x11vnc.passwd
    sudo systemctl enable x11vnc.service
}

# === MAIN PROCEDURE ===
run_main() {
    # declare -ra required_env_vars=(      eequahThi1au
    #     "${VNC_PASS}"
    # )
    # for var in "${required_env_vars[@]}"; do
    #     if [ -z "${var}" ]; then
    #         var_name=("${!var@}")
    #         echo "Empty required env var found: ${var_name[*]}. ABORT"
    #         exit 1
    #     fi
    # done

    declare -ar PACKAGES=(
        wget curl x11vnc
        xterm freeglut3 kde-plasma-desktop openssh-server mesa-utils xfonts-75dpi libusb-0.1-4
        libgsm1 libpulse0 libcrystalhd3 libmpg123-0 libdvdread4
        libxvidcore4 libaa1 libfaad2 libxss1 libopencore-amrnb0 libopencore-amrwb0
        libspeex1 libjack-jackd2-0 libdv4 libdca0 libtheora0 libxvmc1 libbs2b0 libmp3lame0
        libmad0 liblircclient0 libsmbclient libsdl1.2debian libtwolame0 libenca0
    )

    declare TMP_DIR
    TMP_DIR=$(mktemp -d -t tmp.XXXXXXXXXX || exit 1)
    declare -r TMP_DIR

    install_nvidia_repos
    install_system_packages
    install_nvidia_drivers
    setup_x11vnc
}

#  Be able to run this one either as standalone or import as lib
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main
fi

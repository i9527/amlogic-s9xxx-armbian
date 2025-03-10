#!/bin/bash
#========================================================================================
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# This file is a part of the Rebuild Armbian
# https://github.com/ophub/amlogic-s9xxx-armbian
#
# Function: Customize the startup script, adding content as needed.
# Dependent script: /etc/rc.local
# File path: /etc/custom_service/start_service.sh
#
#========================================================================================

# Custom Service Log
custom_log="/tmp/ophub_start_service.log"

# Add custom log
echo "[$(date +"%Y.%m.%d.%H:%M:%S")] Start the custom service..." >${custom_log}

# Set the release check file
ophub_release_file="/etc/ophub-release"
[[ -f "${ophub_release_file}" ]] && FDT_FILE="$(cat ${ophub_release_file} | grep -oE 'meson.*dtb')" || FDT_FILE=""
# For Tencent Aurora 3Pro (s905x3-b) box [ /etc/modprobe.d/blacklist.conf : blacklist btmtksdio ]
[[ "${FDT_FILE}" == "meson-sm1-skyworth-lb2004-a4091.dtb" ]] && {
    modprobe btmtksdio 2>/dev/null &&
        echo "[$(date +"%Y.%m.%d.%H:%M:%S")] The Tencent-Aurora-3Pro's btmtksdio module loaded successfully." >>${custom_log}
}

# Restart ssh service
[[ -d "/var/run/sshd" ]] || mkdir -p -m0755 /var/run/sshd 2>/dev/null
[[ -f "/etc/init.d/ssh" ]] && {
    sleep 5 && /etc/init.d/ssh restart 2>/dev/null &&
        echo "[$(date +"%Y.%m.%d.%H:%M:%S")] The ssh service restarted successfully." >>${custom_log}
}

# Add network performance optimization
[[ -x "/usr/sbin/balethirq.pl" ]] && {
    perl /usr/sbin/balethirq.pl 2>/dev/null &&
        echo "[$(date +"%Y.%m.%d.%H:%M:%S")] The network optimization service started successfully." >>${custom_log}
}

# Led display control
openvfd_enable="no"
openvfd_boxid="15"
[[ "${openvfd_enable}" == "yes" && -n "${openvfd_boxid}" && -x "/usr/sbin/armbian-openvfd" ]] && {
    armbian-openvfd ${openvfd_boxid} &&
        echo "[$(date +"%Y.%m.%d.%H:%M:%S")] The openvfd service started successfully." >>${custom_log}
}

# For vplus(Allwinner h6) led color lights
[[ -x "/usr/bin/rgb-vplus" ]] && {
    rgb-vplus --RedName=RED --GreenName=GREEN --BlueName=BLUE 2>/dev/null &
    echo "[$(date +"%Y.%m.%d.%H:%M:%S")] The LED of Vplus is enabled successfully." >>${custom_log}
}

# Enable Realtek protocol Bluetooth support (https://post.smzdm.com/p/a8xm0rkq/)
rtk_bluetooth="no"
[[ "${rtk_bluetooth}" == "yes" ]] && {
    /usr/bin/rtk_hciattach -n -s 115200 ttyAML1 rtk_h5 2>/dev/null &
    gpioset -s 1 -m time 0 82=0 2>/dev/null
    gpioset 0 82=1 2>/dev/null
    echo "[$(date +"%Y.%m.%d.%H:%M:%S")] Realtek protocol bluetooth enabled successfully." >>${custom_log}
}

# Add custom log
echo "[$(date +"%Y.%m.%d.%H:%M:%S")] All custom services executed successfully!" >>${custom_log}

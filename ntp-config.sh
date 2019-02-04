#!/bin/bash
#IPAddressList
SYSTEM_PRESET_FILE=/usr/lib/systemd/system-preset/90-default.preset
NTP_UNIT_DIR=/usr/lib/systemd/ntp-units.d
NTP_CONF_FILE=/etc/ntp.conf
DHCP_CONF_DIRECTORY=/etc/dhcp
BACKUP_LOCATION=~esmadmin/backups
OPT=${1}
VALUE=${2}
PREF_NTP_FROM=${2} #chronyd #Choose ntpd or chronyd
PREF_NTP_TO=${3} #ntpd
PRIMARY_NTP_SERVER=${2}#164.248.238.69
SECONDARY_NTP_SERVER=${3}#164.248.238.70


function USAGE {
  if [ ${OPT} == null || ${VALUE} == null ]
    then
      cat <<-EOF
usage: $(basename $0) [OPTION] [VALUE]
                      [Backup_NTP]
                      [Update_Default_Preset] [NTP NAME FROM] [NTP NAME FROM]
                      [Update_NTP_UNIT] [NTP NAME FROM] [NTP NAME FROM]
                      [UpdateNTP_From_Hostname_IP] [PRIMARY NTP SERVER] [SECONDARY NTP SERVER]
                      [Deactivate_NTP_DHCLIENT] [NTP NAME FROM] [NTP NAME FROM]
                      [Initiate_NTP]
EOF
  else
    ${OPT} ${VALUE}
  fi
}

function Backup_NTP {
  local Cdate=$(date +%Y%m%d)
  tar cvfP ${BACKUP_LOCATION}/ntp_configuration_backup_${Cdate}.tar ${NTP_UNIT_DIR} ${NTP_CONF_FILE} ${SYSTEM_PRESET_FILE}
}

function Update_Default_Preset {
  if [ -f ${SYSTEM_PRESET_FILE} ]
    then
      sed -i "s/${PREF_NTP_FROM}/${PREF_NTP_TO}/" ${SYSTEM_PRESET_FILE}
  else
    echo "Can not locate the file informaotion"
  fi
}

function Update_NTP_UNIT {
  local RUNLEVEL_PREFIX_FROM=$(ls|grep "${PREF_NTP_FROM}" |sed 's/-.*//')
  local RUNLEVEL_POSTFIX_FROM=$(ls|grep "${PREF_NTP_FROM}" |sed 's/.*-//')
  local RUNLEVEL_PREFIX_TO=$(ls|grep "${PREF_NTP_TO}" |sed 's/-.*//')
  local RUNLEVEL_POSTFIX_TO=$(ls|grep "${PREF_NTP_TO}" |sed 's/.*-//')
  if [ ${RUNLEVEL_PREFIX_TO} -gt ${RUNLEVEL_PREFIX_FROM} ]
    then
      mv ${RUNLEVEL_PREFIX_TO}-${RUNLEVEL_POSTFIX_FROM} ${RUNLEVEL_PREFIX_FROM}-${RUNLEVEL_POSTFIX_FROM}
      mv ${RUNLEVEL_PREFIX_FROM}-${RUNLEVEL_POSTFIX_TO} ${RUNLEVEL_PREFIX_TO}-${RUNLEVEL_POSTFIX_TO}
    else
      echo "NTP-UNIT list does NOT need any changes"
  fi
}

function UpdateNTP_From_Hostname_IP {
  if [ -f ${NTP_CONF_FILE} ]
    then
    sed -i "/^server*/d" ${NTP_CONF_FILE}
    /bin/cat <<-EOF >> ${NTP_CONF_FILE}
server ${PRIMARY_NTP_SERVER}
server ${SECONDARY_NTP_SERVER}
EOF
  else
    echo "ntp.conf does NOT exist"
  fi
}

function Deactivate_NTP_DHCLIENT.D {
  chmod -x ${DHCP_CONF_DIRECTORY}/dhclient.d/${PREF_NTP_FROM}.sh
  chmod +x ${DHCP_CONF_DIRECTORY}/dhclient.d/${PREF_NTP_TO}.sh
}

function Initiate_NTP {
  timedatectl set-ntp false
  timedatectl set-ntp true
  systemctl restart ntpd
}

case $OPT in
-a)
        if [ ${#2} != 0 ] && [ ${#3} != 0 ] && [ ${#4} == 0 ]
                then
                    A ${2} ${3}
        else
                echo "Invalid Options"
        fi;;
-b)
    B ${2} ;;
-c)
    C ${2} ${3} ${4} ;;

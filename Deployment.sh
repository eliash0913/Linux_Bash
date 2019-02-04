#!/bin/bash

OPT=${1}
VALUE=${2}

function USAGE {
  if [ ${OPT} == null || ${VALUE} == null ]
    then
      cat <<-EOF
usage: $(basename $0) [OPTION] [VALUE]
                      [SET_HOSTNAME] [HOSTNAME]
                      [SET_ENV] [ENVIROMENT]
                      [SET_LOCATION] [LOCATION]
EOF
  else
    ${OPT} ${VALUE}
  fi
}

function DEVICE_INFORMATION { #get device information from list that has ECN/MAC/IP/HOSTNAME

}

function LOCK_DHCP_CONF {
  chattr +i /etc/dhcp/dhclient.conf
}

function SET_HOSTNAME {
  SET_CONFIGURATION network.hostName ${1}
}

function SET_ENV {
  SET_CONFIGURATION env ${1}
}

function SET_LOCATION {
  SET_CONFIGURATION locations ${1}
}

function SET_CONFIGURATION {
      local OPTION=${1} #hostName, ENV
      local NAME=${2}
      local APPLIANCE_CONF=/home/esmadmin/CareAware/Appliance/configuration/appliance-configuration.xml
      local GRAB_BEGIN=$(awk "/<Context key=\"appliance.settings.${OPTION}\">/{ print NR }" ${APPLIANCE_CONF})
      local GRAB_END=" </Context>"
      local GRAB_MAIN_LINE=$(expr ${GRAB_BEGIN} + 1)
      local GRAB_END_LINE=$(expr ${GRAB_MAIN_LINE} + 1)
      local GRAB_END_LINE_COMPARE=$(sed "${GRAB_END_LINE}q;d" ${APPLIANCE_CONF})
      if [ ${GRAB_END} == ${GRAB_END_LINE_COMPARE} ]
      then
        sed -i "${GRAB_MAIN_LINE}s/^.*/     <Value><\![CDATA[<string>${NAME}<\/string>]]><\/Value>/" ${APPLIANCE_CONF}
      else
        sed -i "${GRAB_MAIN_LINE}s/^.*/     <Value><\![CDATA[<string>${NAME}<\/string>]]><\/Value>/" ${APPLIANCE_CONF}
        sed -i "${GRAB_END_LINE} i\ ${GRAB_END}" ${APPLIANCE_CONF}
      fi
}

function KERNEL_TUNING {
  sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT.*$/d' /etc/default/grub
  cat <<-EOF >> /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="intel_idle.max_cstate=1 idle=poll intel_pstate=disable apm=off pcie_aspm=off i915.enable_rc6=0 i915.enable_fbc=0 i915.semaphores=1 pnpbios=off acpi_osi=linux"
EOF
grub2-mkconfig -o /boot/grub2/grub.cfg
}

function NTP_CONFIGURATION {

}

USAGE
exit 0

#!/bin/bash
#############################################
#Script is used to print server information #
#in markdown specs (used for git Wiki)      #
#############################################

###Commands
cmd_version="$(cat /etc/*-release)"
cmd_hardware="$(uname -m)"
cmd_kernel="$(uname -r)"
cmd_cpu="$(egrep 'processor|MHz' /proc/cpuinfo)"
cmd_ram="$(cat /proc/meminfo | grep MemTotal)"
cmd_hdd="$(df -lh)"
cmd_fstype="$(df -Th)"
cmd_network="$(ip addr)"

print_command(){
   local cmd=${!1}
   local title=${2}
   echo
   echo
   echo -e "## $title (${1})"
   echo -e "\`\`\`conf"
   echo "$cmd"
   echo -e "\`\`\`"
}

print_command cmd_version "Version"
print_command cmd_hardware Hardware
print_command cmd_kernel Kernel
print_command cmd_cpu CPU
print_command cmd_ram RAM
print_command cmd_hdd HDD
print_command cmd_fstype "File system types"
print_command cmd_network Network
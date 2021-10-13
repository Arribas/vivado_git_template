#!/bin/bash
usage() { 
 echo "Usage: $0 [-l /path_to_license_file.lic]"
 exit 1;
}

while getopts ":l:" options; do
    case "${options}" in
        l)
            licpath=${OPTARG}
            echo "license path set to ${licpath}"
            ;;
        :) # If expected argument omitted:
          echo "Error: -${OPTARG} requires an argument."
           ;;
        *)
            usage
            ;;
    esac
done
if [ "$licpath" = "" ]; then
 usage
fi
export XILINXD_LICENSE_FILE=${licpath}
vivado -source vivado_startup.tcl

#!/bin/bash

### read in user settings


if [ "$1" = "" ] ; then
	echo "This script sets up running directories for ERA5 downloads."
    echo "usage: STEP01_setup_ERA5_downloads.sh [global settings file]"
    exit
fi

source $1


### fixed settings

era5_input_root=/mnt/eps01-rds/turing_air_health/Britain_Breathing_Operational_Inputs/ERA5/
scripts_root=${era5_input_root}ERA5_download_scripts/

download_script_template=${scripts_root}batch_download_template.sh
download_script=batch_download.sh
python_template=${scripts_root}download_template.py
python_script=download.py


### create script settings

download_directory=${working_general_root}/${jobid}/download_ERA5/



### working code

mkdir -p ${download_directory}

sed -e "s|%%JOBID%%|$jobid|" \
		${download_script_template} > ${download_directory}${download_script}


sed -e "s|%%YRST%%|$start_year|g" \
		-e "s|%%MONST%%|$start_month|g" \
		-e "s|%%DAYST%%|$start_day|g" \
		-e "s|%%YREND%%|$end_year|g" \
		-e "s|%%MONEND%%|$end_month|g" \
		-e "s|%%DAYEND%%|$end_day|g" \
		${python_template} > ${download_directory}${python_script} 




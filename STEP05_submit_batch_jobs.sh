#!/bin/bash

### read in user settings


if [ "$1" = "" ] ; then
	echo "This script sets up running directories for EMEP."
    echo "usage: STEP05_submit_batch_jobs.sh [global settings file]"
    exit
fi

source $1



### fixed settings

download_script=batch_download.sh
wps_script=batch_automate_ungrib_metgrid.sh
real_scripts=( 'batch_real_europe.sh' 'batch_real_uk.sh' )
wrf_scripts=( 'batch_wrf_europe.sh' 'batch_wrf_uk.sh' )
emep_scripts=( 'batch_emep_europe.sh' 'batch_emep_uk.sh' )

### create script settings

download_directory=${working_general_root}/${jobid}/download_ERA5/
wps_directory=${working_general_root}/${jobid}/WPS_Operations/
wrf_directory=${working_general_root}/${jobid}/WRF_Operations/
emep_directory=${working_general_root}/${jobid}/EMEP_Operations/


### working code

cd ${download_directory}
qsub ${download_script}
sleep 2

cd ${wps_directory}
qsub ${wps_script}
sleep 2

cd ${wrf_directory}
for real_script in ${real_scripts[@]}
do
	qsub ${real_script}
	sleep 2
done
for wrf_script in ${wrf_scripts[@]}
do
	qsub ${wrf_script}
	sleep 2
done

cd ${emep_directory}
for emep_script in ${emep_scripts[@]}
do
	qsub ${emep_script}
	sleep 2
done






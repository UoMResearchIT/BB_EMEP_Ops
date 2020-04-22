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
real_script=batch_real_job_array.sh
wrf_script=batch_wrf_job_array.sh
emep_script=batch_emep_job_array.sh


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
qsub ${real_script}
sleep 2
qsub ${wrf_script}
sleep 2

cd ${emep_directory}
qsub ${emep_script}
sleep 2







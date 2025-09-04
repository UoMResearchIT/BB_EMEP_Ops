#!/bin/bash

### read in user settings


if [ "$1" = "" ] ; then
	echo "This script sets up running directories for EMEP."
    echo "usage: STEP06_submit_batch_jobs.sh [global settings file]"
    exit
fi

source $1

jobid_calc ()
{
        JOBID_VALUE=$(squeue --noheader --format %i --name ${NAMETAG})
}

### fixed settings

download_script=batch_download.sh
wps_script=batch_automate_ungrib_metgrid.sh
real_scripts=( 'batch_real_europe.sh' 'batch_real_uk.sh' )
ndown_scripts=( 'batch_ndown_uk.sh' )
wrf_scripts=( 'batch_wrf_europe.sh' 'batch_wrf_outer_uk.sh' 'batch_wrf_uk.sh' )
emep_scripts=( 'batch_emep_europe.sh' 'batch_emep_uk_45km.sh' 'batch_emep_uk_3km.sh' )
postproc_scripts=( 'batch_extract_45km.sh' 'batch_extract_3km.sh' )

era_ID=( 'ERA5-' )
wps_ID=( 'WPS-' )
real_ID=( 'REAL-EU-' 'REAL-UK-' )
ndown_ID=( 'NDOWN-UK-' )
wrf_ID=( 'WRF-EU-' 'WRF-OUTERUK-' 'WRF-UK-' )
emep_ID=( 'EMEP-EU-' 'EMEP-UK45-' 'EMEP-UK3-' )
post_ID=( 'DATA-45km-' 'DATA-3km-' )

### create script settings

download_directory=${working_general_root}/${jobid}/download_ERA5/
wps_directory=${working_general_root}/${jobid}/WPS_Operations/
wrf_directory=${working_general_root}/${jobid}/WRF_Operations/
emep_directory=${working_general_root}/${jobid}/EMEP_Operations/
postproc_directory=${working_general_root}/${jobid}/Data_Extraction/

### working code

cd ${download_directory}
sbatch ${download_script}
sleep 2

NAMETAG=${era_ID[0]}${jobid}; jobid_calc; ERAID=${JOBID_VALUE}
cd ${wps_directory}
sbatch --dependency=aftercorr:${ERAID} ${wps_script}
sleep 2

NAMETAG=${wps_ID[0]}${jobid}; jobid_calc; WPSID=${JOBID_VALUE}
cd ${wrf_directory}
for real_script in ${real_scripts[@]}
do
	sbatch --dependency=aftercorr:${WPSID} ${real_script}
	sleep 2
done
NAMETAG=${real_ID[0]}${jobid}; jobid_calc; REALID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${REALID} ${wrf_scripts[0]}
sleep 2
NAMETAG=${real_ID[1]}${jobid}; jobid_calc; REALID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${REALID} ${wrf_scripts[1]}
sleep 2
NAMETAG=${wrf_ID[1]}${jobid}; jobid_calc; WRFOUTERUKID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${WRFOUTERUKID} ${ndown_scripts[0]}
sleep 2
NAMETAG=${ndown_ID[0]}${jobid}; jobid_calc; NDOWNUKID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${NDOWNUKID} ${wrf_scripts[2]}
sleep 2

cd ${emep_directory}
NAMETAG=${wrf_ID[0]}${jobid}; jobid_calc; WRFEU_ID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${WRFEU_ID} ${emep_scripts[0]}
sleep 2

NAMETAG=${emep_ID[0]}${jobid}; jobid_calc; EMEPEU_ID=${JOBID_VALUE}
NAMETAG=${wrf_ID[1]}${jobid}; jobid_calc; WRFOUTERUK_ID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${WRFOUTERUK_ID}:${EMEPEU_ID} ${emep_scripts[1]}
sleep 2

NAMETAG=${emep_ID[1]}${jobid}; jobid_calc; EMEPOUTERUK_ID=${JOBID_VALUE}
NAMETAG=${wrf_ID[2]}${jobid}; jobid_calc; WRFUK_ID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${WRFUK_ID}:${EMEPOUTERUK_ID} ${emep_scripts[2]}
sleep 2

cd ${postproc_directory}
NAMETAG=${emep_ID[1]}${jobid}; jobid_calc; EMEPOUTERUK_ID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${EMEPOUTERUK_ID} ${postproc_scripts[0]}
NAMETAG=${emep_ID[2]}${jobid}; jobid_calc; EMEPUK_ID=${JOBID_VALUE}
sbatch --dependency=aftercorr:${EMEPUK_ID} ${postproc_scripts[1]}



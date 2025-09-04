#!/bin/bash

### read in user settings


if [ "$1" = "" ] ; then
	echo "This script sets up running directories for Post Processing."
    echo "usage: STEP05_setup_PostProc.sh [global settings file]"
    exit
fi

source $1




### fixed settings

post_input_root=/mnt/eps01-rds/turing_air_health/Operational_Inputs/EMEP_Workflow_Ops_Inputs/PostProc/

post_scripts=${post_input_root}Data_Extraction/

processing_script='data_extraction.py'

batchfile_template='batch_extract_template.sh'

BATCH_SCRIPT_NAMES=( 'batch_extract_45km.sh' 'batch_extract_3km.sh' )
DOMAINS=( '45km' '3km' )
WRF_DIRECTORIES=( 'UK_WRF_45km' 'UK_3km' )
OUT_DIRECTORIES=( 'UK_45km' 'UK_3km' )
EMEP_DIRECTORIES=( 'UK_45km_domain/domain2_output' 'UK_3km_domain/domain3_output ' )

### create script settings

working_directory=${working_general_root}/${jobid}/Data_Extraction/
emep_base_directory=${working_general_root}/${jobid}/EMEP_Operations/
wrf_base_directory=${working_general_root}/${jobid}/WRF_Operations/
out_base_directory=${output_general_root}/${jobid}/


### working code


# create workspace
mkdir -p ${working_directory}
mkdir -p ${out_base_directory}${OUT_DIRECTORIES[0]}
mkdir -p ${out_base_directory}${OUT_DIRECTORIES[1]}


# copy the Post Processing batch scripts, setting required information
#for batchfile_template in ${BATCH_SCRIPT_TEMPLATES[@]}
for i in $(seq 0 1);
do
	batchfile=${BATCH_SCRIPT_NAMES[$i]}
	domain=${DOMAINS[$i]}
	wrf_directory=${wrf_base_directory}${WRF_DIRECTORIES[$i]}
	emep_directory=${emep_base_directory}${EMEP_DIRECTORIES[$i]}
	out_directory=${out_base_directory}${OUT_DIRECTORIES[$i]}
	sed -e "s|%%DOM%%|${domain}|g" \
		-e "s|%%JOBID%%|${jobid}|g" \
		-e "s|%%POSTPROCDIR%%|${working_directory}|g" \
		-e "s|%%YRST%%|${start_year}|g" \
		-e "s|%%MONST%%|${start_month}|g" \
		-e "s|%%DAYST%%|${start_day}|g" \
		-e "s|%%YREND%%|${end_year}|g" \
		-e "s|%%MONEND%%|${end_month}|g" \
		-e "s|%%DAYEND%%|${end_day}|g" \
		-e "s|%%WRFDIR%%|${wrf_directory}|g" \
		-e "s|%%EMEPDIR%%|${emep_directory}|g" \
		-e "s|%%OUTDIR%%|${out_directory}|g" \
		${post_scripts}/${batchfile_template} > ${working_directory}${batchfile}
done

# copy processing script
cp -a ${post_scripts}${processing_script} ${working_directory}




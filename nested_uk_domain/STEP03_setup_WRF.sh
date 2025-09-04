#!/bin/bash

### read in user settings

if [ "$1" = "" ] ; then
	echo "This script sets up running directories for WRF."
    echo "usage: STEP02_setup_WRF.sh [global settings file]"
    exit
fi

source $1


### fixed settings

#load WRF module for paths
module load apps/gcc/wrf/4.5

wrf_input_root=/mnt/eps01-rds/turing_air_health/Operational_Inputs/EMEP_Workflow_Ops_Inputs/WRF/

wrf_run_template=${WRF_RUNDIR}
wrf_namelists=${wrf_input_root}namelist_templates/


NAMELIST_FILES=( 'namelist.input.3km_UK_NDOWN.30vlevels'  \
                 'namelist.input.3km_UK_WRF.30vlevels'  \
                 'namelist.input.45km_UK_REAL.30vlevels.analysis_nudging' \
                 'namelist.input.45km_UK_WRF.30vlevels.analysis_nudging' \
				 'namelist.input.50km_EMEP_REAL.30vlevels.analysis_nudging' \
				 'namelist.input.50km_EMEP_WRF.30vlevels.analysis_nudging' )

BATCH_SCRIPT_TEMPLATES=( 'batch_real_europe_template.sh' 'batch_real_uk_template.sh' \
						 'batch_wrf_europe_template.sh' 'batch_wrf_outer_uk_template.sh' \
						 'batch_ndown_uk_template.sh' 'batch_wrf_uk_template.sh' )

batch_templates=${wrf_input_root}batch_script_templates/



### create script settings

working_directory=${working_general_root}/${jobid}/WRF_Operations/

wps_directory=${working_general_root}/${jobid}/WPS_Operations/

wrf_working_namelists=${working_directory}/namelists/


### working code


# create workspace
mkdir -p ${working_directory}
mkdir -p ${wrf_working_namelists}


# copy the REAL and WRF batch scripts, setting required information
for batchfile_template in ${BATCH_SCRIPT_TEMPLATES[@]}
do
	batchfile=${batchfile_template//_template/}
	sed -e "s|%%JOBID%%|${jobid}|g" \
		-e "s|%%WRFDIR%%|${working_directory}|g" \
		-e "s|%%WPSDIR%%|${wps_directory}|g" \
		${batch_templates}/${batchfile_template} > ${working_directory}${batchfile}
done




# copy the namelist files, setting date information
for namefile in ${NAMELIST_FILES[@]}
do
	sed -e "s|%%YRST%%|${start_year}|g" \
		-e "s|%%MONST%%|${start_month}|g" \
		-e "s|%%DAYST%%|${start_day}|g" \
		-e "s|%%YREND%%|${end_year}|g" \
		-e "s|%%MONEND%%|${end_month}|g" \
		-e "s|%%DAYEND%%|${end_day}|g" \
		${wrf_namelists}/${namefile}.template \
		 > ${wrf_working_namelists}/${namefile}
done



# setup the EMEP 50km domain REAL working directory
cp -a ${wrf_run_template} ${working_directory}/EMEP_REAL_50km
cd ${working_directory}/EMEP_REAL_50km
ln -s ${wrf_working_namelists}/namelist.input.50km_EMEP_REAL.30vlevels.analysis_nudging namelist.input


# setup the EMEP 50km domain WRF working directory
cp -a ${wrf_run_template} ${working_directory}/EMEP_WRF_50km
cd ${working_directory}/EMEP_WRF_50km
ln -s ${wrf_working_namelists}/namelist.input.50km_EMEP_WRF.30vlevels.analysis_nudging namelist.input

# setup the UK 45km / 9km / 3km domain REAL working directory
cp -a ${wrf_run_template} ${working_directory}/UK_REAL_45km
cd ${working_directory}/UK_REAL_45km
ln -s ${wrf_working_namelists}/namelist.input.45km_UK_REAL.30vlevels.analysis_nudging namelist.input

# setup the UK 45km / 9km WRF working directory
cp -a ${wrf_run_template} ${working_directory}/UK_WRF_45km
cd ${working_directory}/UK_WRF_45km
ln -s ${wrf_working_namelists}/namelist.input.45km_UK_WRF.30vlevels.analysis_nudging namelist.input

# setup the UK 3km domain NDOWN working directory
cp -a ${wrf_run_template} ${working_directory}/UK_NDOWN_3km
cd ${working_directory}/UK_NDOWN_3km
ln -s ${wrf_working_namelists}/namelist.input.3km_UK_NDOWN.30vlevels namelist.input


# setup the UK 3km domain WRF working directory
cp -a ${wrf_run_template} ${working_directory}/UK_3km
cd ${working_directory}/UK_3km
ln -s ${wrf_working_namelists}/namelist.input.3km_UK_WRF.30vlevels namelist.input





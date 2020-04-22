#!/bin/bash

### read in user settings

if [ "$1" = "" ] ; then
	echo "This script sets up running directories for WRF."
    echo "usage: STEP02_setup_WRF.sh [global settings file]"
    exit
fi

source $1


### fixed settings

wrf_input_root=/mnt/eps01-rds/turing_air_health/Britain_Breathing_Operational_Inputs/WRF/

wrf_run_template=${wrf_input_root}run_template_intel/
wrf_namelists=${wrf_input_root}namelist_templates/
wrf_executables=${wrf_input_root}executables/intel_compiled_fpmath_precise/


NAMELIST_FILES=( 'namelist.input.3km_UK.30vlevels'  \
				 'namelist.input.50km_EMEP_REAL.30vlevels.analysis_nudging' \
				 'namelist.input.50km_EMEP_WRF.30vlevels.analysis_nudging' )

batch_real_script_template=${wrf_input_root}batch_script_templates/batch_real_job_array_template.sh
batch_real_script=batch_real_job_array.sh

batch_wrf_script_template=${wrf_input_root}batch_script_templates/batch_wrf_job_array_template.sh
batch_wrf_script=batch_wrf_job_array.sh


### create script settings

working_directory=${working_general_root}/${jobid}/WRF_Operations/

wps_directory=${working_general_root}/${jobid}/WPS_Operations/

wrf_working_namelists=${working_directory}/namelists/
wrf_working_executables=${working_directory}/executables/


### working code


# create workspace
mkdir -p ${working_directory}
mkdir -p ${wrf_working_namelists}


# copy the REAL batch script, setting required information
sed -e "s|%%JOBID%%|${jobid}|g" \
	-e "s|%%WRFDIR%%|${working_directory}|g" \
	-e "s|%%WPSDIR%%|${wps_directory}|g" \
	${batch_real_script_template} > ${working_directory}${batch_real_script}

# copy the WRF batch script, setting required information
sed -e "s|%%JOBID%%|${jobid}|g" \
	-e "s|%%WRFDIR%%|${working_directory}|g" \
	-e "s|%%WPSDIR%%|${wps_directory}|g" \
	${batch_wrf_script_template} > ${working_directory}${batch_wrf_script}



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

# copy executables
cp -a ${wrf_executables} ${wrf_working_executables}


# setup the EMEP 50km domain REAL working directory
cp -a ${wrf_run_template} ${working_directory}/EMEP_REAL_50km
cd ${working_directory}/EMEP_REAL_50km
ln -s ${wrf_working_executables}/*exe .
ln -s ${wrf_working_namelists}/namelist.input.50km_EMEP_REAL.30vlevels.analysis_nudging namelist.input


# setup the EMEP 50km domain WRF working directory
cp -a ${wrf_run_template} ${working_directory}/EMEP_WRF_50km
cd ${working_directory}/EMEP_WRF_50km
ln -s ${wrf_working_executables}/*exe .
ln -s ${wrf_working_namelists}/namelist.input.50km_EMEP_WRF.30vlevels.analysis_nudging namelist.input

# setup the UK 3km domain working directory
cp -a ${wrf_run_template} ${working_directory}/UK_3km
cd ${working_directory}/UK_3km
ln -s ${wrf_working_executables}/*exe .
ln -s ${wrf_working_namelists}/namelist.input.3km_UK.30vlevels namelist.input





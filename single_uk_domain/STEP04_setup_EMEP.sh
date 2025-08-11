#!/bin/bash

### read in user settings


if [ "$1" = "" ] ; then
	echo "This script sets up running directories for EMEP."
    echo "usage: STEP04_setup_EMEP.sh [global settings file]"
    exit
fi

source $1




### fixed settings

emep_input_root=/mnt/eps01-rds/turing_air_health/Britain_Breathing_Operational_Inputs/EMEP/

emep_namelists=${emep_input_root}namelist_templates/
emep_executables=${emep_input_root}executables/

NAMELIST_FILES=( 'config_emep.nml.UK_3km'  \
				 'config_emep.nml.EMEP_50km' )

BATCH_SCRIPT_TEMPLATES=( 'batch_emep_europe_template.sh' 'batch_emep_uk_template.sh' )
batch_templates=${emep_input_root}batch_script_templates/


emep_executable_name='emepctm-r3_44-mpi_418-vert_read_fix-emiss_sector_read_fix-more_emission_variables'

### create script settings

working_directory=${working_general_root}/${jobid}/EMEP_Operations/
wrf_directory=${working_general_root}/${jobid}/WRF_Operations/

emep_working_namelists=${working_directory}namelists/
emep_working_executables=${working_directory}executables/

emep_input_data=${emep_input_root}${emep_data}/
emep_working_data=${working_directory}${emep_data}/

emep_exec=${emep_working_executables}/${emep_executable_name}


### working code


# create workspace
mkdir -p ${working_directory}
mkdir -p ${emep_working_namelists}


# copy the EMEP batch scripts, setting required information
for batchfile_template in ${BATCH_SCRIPT_TEMPLATES[@]}
do
	batchfile=${batchfile_template//_template/}
	sed -e "s|%%JOBID%%|${jobid}|g" \
		-e "s|%%WRFDIR%%|${wrf_directory}|g" \
		-e "s|%%EMEPDIR%%|${working_directory}|g" \
		-e "s|%%EMEPEXEC%%|${emep_exec}|g" \
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
		-e "s|%%YROUT%%|${output_year}|g" \
		-e "s|%%MONOUT%%|${output_month}|g" \
		-e "s|%%DAYOUT%%|${output_day}|g" \
		${emep_namelists}/${namefile}.template \
		 > ${emep_working_namelists}/${namefile}
done



# copy input data
cp -a ${emep_input_data} ${emep_working_data}


# copy executables
cp -a ${emep_executables} ${emep_working_executables}

# create EMEP 50km working directory
mkdir ${working_directory}EMEP_domain
cd ${working_directory}EMEP_domain
mkdir domain1_output
ln -s ${emep_working_namelists}/config_emep.nml.EMEP_50km config_emep.nml
ln -s ${emep_working_data} input_data

# create UK 3km working directory
mkdir ${working_directory}UK_domain
cd ${working_directory}UK_domain
ln -s ${working_directory}EMEP_domain/domain1_output .
ln -s ${emep_working_namelists}/config_emep.nml.UK_3km config_emep.nml
ln -s ${emep_working_data} input_data

# make meteorology directory
mkdir -p ${working_directory}/wrf_meteo/EMEP_grid
mkdir -p ${working_directory}/wrf_meteo/UK_grid


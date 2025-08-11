#!/bin/bash

### read in user settings

if [ "$1" = "" ] ; then
	echo "This script sets up running directories for WPS."
    echo "usage: STEP02_setup_WPS.sh [global settings file]"
    exit
fi

source $1


### fixed settings

# load WPS module for paths
module load apps/gcc/wps/4.5

wps_input_root=/mnt/eps01-rds/turing_air_health/Britain_Breathing_Operational_Inputs/WPS/

wps_dir_template=${WPS_RUNDIR}
wps_altVtables=${wps_input_root}alt_Vtables/
wps_namelists=${wps_input_root}namelist_templates/
wps_geogrid_data=${wps_input_root}geo_grid_data/



NAMELIST_FILES=( 'namelist.wps.ungrib_sfc' 'namelist.wps.ungrib_atm' \
				'namelist.wps.emep_50km' 'namelist.wps.emep_uk3km' )

batch_script_template=${wps_input_root}batch_script_templates/batch_automate_ungrib_metgrid_template.sh
batch_script=batch_automate_ungrib_metgrid.sh


### create script settings

download_directory=${working_general_root}/${jobid}/download_ERA5/

working_directory=${working_general_root}/${jobid}/WPS_Operations/

wps_working_namelists=${working_directory}namelists/
wps_working_geogrid_data=${working_directory}geo_grid_data/



### working code

# create working directories
mkdir -p ${working_directory}
mkdir -p ${wps_working_namelists}

# copy the geogrid files
cp -a ${wps_geogrid_data} ${wps_working_geogrid_data}


# copy the batch script, setting required information
sed -e "s|%%JOBID%%|${jobid}|g" \
	-e "s|%%WPSDIR%%|${working_directory}|g" \
	-e "s|%%ERA5DIR%%|${download_directory}|g" \
	${batch_script_template} > ${working_directory}${batch_script}


# reformat the date strings to please WPS
wps_start_year=$(printf '%.4i' ${start_year})
wps_start_month=$(printf '%.2i' ${start_month})
wps_start_day=$(printf '%.2i' ${start_day})
wps_end_year=$(printf '%.4i' ${end_year})
wps_end_month=$(printf '%.2i' ${end_month})
wps_end_day=$(printf '%.2i' ${end_day})


# copy the namelist files, setting date information
for namefile in ${NAMELIST_FILES[@]}
do
	sed -e "s|%%YRST%%|${wps_start_year}|g" \
		-e "s|%%MONST%%|${wps_start_month}|g" \
		-e "s|%%DAYST%%|${wps_start_day}|g" \
		-e "s|%%YREND%%|${wps_end_year}|g" \
		-e "s|%%MONEND%%|${wps_end_month}|g" \
		-e "s|%%DAYEND%%|${wps_end_day}|g" \
		${wps_namelists}/${namefile}.template \
		 > ${wps_working_namelists}/${namefile}
done


# setup atmospheric ungrib workspace
cp -a ${wps_dir_template} ${working_directory}WPS_UNGRIB_ATM
cp -a ${wps_altVtables} ${working_directory}WPS_UNGRIB_ATM/ungrib/Variable_Tables/
cd ${working_directory}WPS_UNGRIB_ATM
ln -s ungrib/Variable_Tables/alt_Vtables/Vtable.ECATM Vtable
ln -s ${wps_working_namelists}/namelist.wps.ungrib_atm namelist.wps

# setup surface ungrib workspace
cp -a ${wps_dir_template} ${working_directory}WPS_UNGRIB_SFC
cp -a ${wps_altVtables} ${working_directory}WPS_UNGRIB_SFC/ungrib/Variable_Tables/
cd ${working_directory}WPS_UNGRIB_SFC
ln -s ungrib/Variable_Tables/alt_Vtables/Vtable.ECSFC Vtable
ln -s ${wps_working_namelists}/namelist.wps.ungrib_sfc namelist.wps


# working directories for correcting polar winds, if we decide this is needed
#cp -a ${wps_dir_template} ${working_wps_root}WPS_correct_ATM
#cp -a ${wps_dir_template} ${working_wps_root}WPS_correct_SFC


# setup UK 3km grid metgrid workspace
cp -a ${wps_dir_template} ${working_directory}WPS_METGRID_3km
cd ${working_directory}WPS_METGRID_3km
ln -s ${wps_working_geogrid_data}UK_3km/geo_em.d01.nc .
ln -s ${wps_working_namelists}/namelist.wps.emep_uk3km namelist.wps

# setup EMEP 50km grid metgrid workspace
cp -a ${wps_dir_template} ${working_directory}WPS_METGRID_50km
cd ${working_directory}WPS_METGRID_50km
ln -s ${wps_working_geogrid_data}EMEP_50km/geo_em.d01.nc .
ln -s ${wps_working_namelists}/namelist.wps.emep_50km namelist.wps




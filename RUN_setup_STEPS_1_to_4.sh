#!/bin/bash

#
#  Script for running Steps 1 & 2 & 3 & 4 of the running directory setup
#    for a list of scenarios (automating the command line actions).
#

WORKFLOW='single_uk_domain'

SCENARIOS=( 'March_2016.txt' )



for scen in ${SCENARIOS[@]}; do

	echo "creating ERA5 download directory for scenario: "${scen}
	bash ${WORKFLOW}/STEP01_setup_ERA5_downloads.sh ${scen}

	echo "creating WPS working directory for scenario: "${scen}
	bash ${WORKFLOW}/STEP02_setup_WPS.sh ${scen}

	echo "creating WRF working directory for scenario: "${scen}
	bash ${WORKFLOW}/STEP03_setup_WRF.sh ${scen}

	echo "creating EMEP working directory for scenario: "${scen}
	bash ${WORKFLOW}/STEP04_setup_EMEP.sh ${scen}

done

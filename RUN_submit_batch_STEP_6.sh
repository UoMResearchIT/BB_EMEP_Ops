#!/bin/bash

#
#  Script for running Steps 1 & 2 & 3 & 4 of the running directory setup
#    for a list of scenarios (automating the command line actions).
#
WORKFLOW='nested_uk_domain'

SCENARIOS=( 'May_2024.txt' )

for scen in ${SCENARIOS[@]}; do

	echo "submitting batch scripts for scenario: "${scen}
	bash ${WORKFLOW}/STEP06_submit_batch_jobs.sh ${scen}

done

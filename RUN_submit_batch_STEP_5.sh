#!/bin/bash

#
#  Script for running Steps 1 & 2 & 3 & 4 of the running directory setup
#    for a list of scenarios (automating the command line actions).
#



SCENARIOS=( 'Jan_Feb_2016.txt' 'July_Aug_2016.txt' 'Mar_Apr_2016.txt' \
			'May_June_2016.txt' 'Nov_Dec_2016.txt' 'Sept_Oct_2016.txt' \
			'July_Aug_2017.txt' 'Mar_Apr_2017.txt' \
			'May_June_2017.txt' 'Nov_Dec_2017.txt' 'Sept_Oct_2017.txt' \
			'Jan_Feb_2018.txt' 'July_Aug_2018.txt' 'Mar_Apr_2018.txt' \
			'May_June_2018.txt' 'Nov_Dec_2018.txt' 'Sept_Oct_2018.txt' \
			'Jan_Feb_2019.txt' 'July_Aug_2019.txt' 'Mar_Apr_2019.txt' \
			'May_June_2019.txt' 'Nov_Dec_2019.txt' 'Sept_Oct_2019.txt' )

SCENARIOS=( 'Mar_Apr_May_2020.txt' )

SCENARIOS=( 'Jan_Feb_2020.txt' 'Mar_Apr_2020.txt' 'May_June_2020.txt' 'July_Aug_2020.txt' 
            'Sept_Oct_2020.txt' 'Nov_Dec_2020.txt' )

SCENARIOS=( 'Nov_Dec_2020.txt' )


for scen in ${SCENARIOS[@]}; do

	echo "submitting batch scripts for scenario: "${scen}
	bash STEP05_submit_batch_jobs.sh ${scen}

done

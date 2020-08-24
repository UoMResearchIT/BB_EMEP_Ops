# BB\_EMEP\_Ops

These scripts are for setting up a workspace for generating EMEP AQ forecasts.

To use these scripts you will need to be on the UoM CSF3 facility, and have access
to the Turing Air Health workspace, where the operational input scripts and 
programs are stored.

These scripts use ERA5 meteorological inputs, downloaded via the CDS API. To get
access to these you will need to accept the licence agreement available here:
https://cds.climate.copernicus.eu/cdsapp/#!/terms/licence-to-use-copernicus-products

Once you have accepted the license, then you will need to save the url and key within
your home directory in the file: .cdsapirc 

You will also need to have installed anaconda, and the cds-api package from conda-forge.

To use these scripts follow this process:
1) copy an example configuration file (either March\_2015.txt or March\_2016.txt), change
the information inside this as you need.
2) edit RUN\_setup\_STEPS\_1\_to\_4.sh, so that your configuration file is listed.
3) bash RUN\_setup\_STEPS\_1\_to\_4.sh
4) check the new working directories - make sure they are okay
5) bash STEP05\_submit\_batch\_jobs.sh [config\_file.txt]

Operational inputs for these scripts are available at: https://doi.org/10.5281/zenodo.3997270

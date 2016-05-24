#!/bin/sh 
cal_fsc.sh opt_r$2\_selected.pdb apix_refined.mrc $1&
cal_fsc.sh starting_INPUTapix_0001.pdb apix_refined.mrc $1&
cal_fsc.sh starting.pdb map.mrc $1&


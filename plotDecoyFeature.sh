#echo "Usage: ${0} <silent_file>"
~/bin/boinc/update_boinc_results.pl run.fold.boinc.job
~/bin/extract_lowscore_decoys.py results/fold.out 100 >top100.out
~/Rosetta_new//main/source/bin/decoy_features.linuxgccrelease -in:file:silent top100.out -in:file:silent_struct_type binary -jd2:no_output -in:file:native 00001.pdb -mute all -contactMap::distance_cutoff 10 > my.bbin.10
~/bin/bakerlab_scripts/utils/make_pbradley_plots.py -ss 00001 -f 00001.200.9mers my.bbin.10
ps2pdf my.bbin.10.ps

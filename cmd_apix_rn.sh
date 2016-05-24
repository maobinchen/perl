#!/bin/bash
if [ $# -lt 4 ]; then
        echo "Usage: $0 <n> <sdf_options> <resolution> <weight>"
        echo "Eg.: $0 2 '-m NCS -a A -i B H' 3.3 35"
        echo "Make sure you have symmetry defintion option, flags file and xml file set up correctly"
        exit 1
fi
echo "$0 $1 $2 $3 $4"
i=`expr $1 - 1`
ln -s ../opt_r$i/apix_refined.mrc map.mrc
ln -s ../opt_r$i/opt_r$i\_selected.pdb starting.pdb
ln -s ../apix.xml
$rosetta/source/src/apps/public/symmetry/make_symmdef_file.pl $2 -r 1000 -p starting.pdb  >symm_def.txt
modify_sym_def.pl symm_def.txt
ln -s ../apix.sh
sh apix.sh
mkdir localrlx
cd localrlx
ln -s ../starting_INPUTapix_0001.pdb starting.pdb
ln -s ../apix_refined.mrc
ln -s ../../localrlx.xml
ln -s ../../localrlx.sh
$rosetta/source/src/apps/public/symmetry/make_symmdef_file.pl $2 -r 1000 -p starting.pdb  >symm_def.txt
modify_sym_def.pl symm_def.txt
parallel -j16 ./localrlx.sh {} ::: {1..16}
exit 0
grep 'FSC' starting_INPUTlocalrlx_*pdb | sed 's/:/ /' | awk '{print $1,$6;}' | sort -nk 2 >fsc.txt
parse_molpro_fsc.pl all_molprob_results.txt fsc.txt >all_molpro_fsc

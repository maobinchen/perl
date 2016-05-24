#!/bin/bash
if [ $# -lt 3 ]; then
        echo "Usage: $0 <n>  <resolution> <weight>"
        echo "Eg.: $0 2 3.3 35"
        exit 1
fi
echo "$0 $1 $2 $3 "
i=`expr $1 - 1`
ln -s ../opt_r$i/apix_refined.mrc map.mrc
ln -s ../opt_r$i/opt_r$i\_selected.pdb starting.pdb
ln -s ../apix.xml
ln -s ../apix.sh
sh apix.sh
mkdir localrlx
cd localrlx
ln -s ../startingapix_0001.pdb starting.pdb
ln -s ../apix_refined.mrc
ln -s ../../localrlx.xml
ln -s ../../localrlx.sh
parallel -j16 ./localrlx.sh {} ::: {1..16}
exit 0
grep 'FSC' startinglocalrlx_*pdb | sed 's/:/ /' | awk '{print $1,$6;}' | sort -nk 2 >fsc.txt
parse_molpro_fsc.pl all_molprob_results.txt fsc.txt >all_molpro_fsc

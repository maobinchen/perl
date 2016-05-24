#!/bin/bash
if [ $# -lt 4 ]; then
        echo "Usage: $0 <full_map_file> <start_pdb> <resolution> <weight>"
        echo "Eg.: $0 1.mrc 1.pdb 3.3 35"
        echo "Make sure you have flags file and xml file set up correctly"
        exit 1
fi
echo "$0 $1 $2 $3 $4"
cp /gscratch/baker/binchen/EM-data_challenge/xmls/flags flags_template
cp /gscratch/baker/binchen/EM-data_challenge/xmls/localrlx_nosym.xml localrlx.xml
cp /gscratch/baker/binchen/EM-data_challenge/xmls/apix_nosym.xml apix.xml
cp /gscratch/baker/binchen/EM-data_challenge/xmls/localrlx.sh localrlx.sh.temp
cp /gscratch/baker/binchen/EM-data_challenge/xmls/apix.sh apix.sh.temp
sed "s/resx/$3/g;s/weight/$4/;s/_INPUT//" localrlx.sh.temp >localrlx.sh
sed "s/resx/$3/g;s/weight/$4/;s/_INPUT//" apix.sh.temp >apix.sh
chmod +x localrlx.sh
ln -s $2 starting.pdb
ln -s  $1  map.mrc
mkdir opt_r1
cd opt_r1
ln -s ../map.mrc
ln -s ../starting.pdb
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
grep 'FSC' starting_INPUTlocalrlx_*pdb | sed 's/:/ /' | awk '{print $1,$6;}' | sort -nk 2 >fsc.txt
parse_molpro_fsc.pl all_molprob_results.txt fsc.txt >all_molpro_fsc

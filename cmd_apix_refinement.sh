#!/bin/bash
if [ $# -lt 5 ]; then
        echo "Usage: $0 <full_map_file> <start_pdb> <sdf_options> <resolution> <weight>"
        echo "Eg.: $0 1.mrc 1.pdb '-m NCS -a A -i B H' 3.3 35"
        echo "Make sure you have symmetry defintion option, flags file and xml file set up correctly"
        exit 1
fi
echo "$0 $1 $2 $3 $4 $5"
cp /gscratch/baker/binchen/EM-data_challenge/xmls/flags flags_template
cp /gscratch/baker/binchen/EM-data_challenge/xmls/localrlx.xml .
cp /gscratch/baker/binchen/EM-data_challenge/xmls/apix.xml .
cp /gscratch/baker/binchen/EM-data_challenge/xmls/localrlx.sh localrlx.sh.temp
cp /gscratch/baker/binchen/EM-data_challenge/xmls/apix.sh apix.sh.temp
sed "s/resx/$4/g;s/weight/$5/" localrlx.sh.temp >localrlx.sh
sed "s/resx/$4/g;s/weight/$5/" apix.sh.temp >apix.sh
chmod +x localrlx.sh
ln -s $2 starting.pdb
ln -s  $1  map.mrc
mkdir opt_r1
cd opt_r1
ln -s ../map.mrc
ln -s ../starting.pdb
ln -s ../apix.xml
$rosetta/source/src/apps/public/symmetry/make_symmdef_file.pl $3 -r 1000 -p starting.pdb  >symm_def.txt
modify_sym_def.pl symm_def.txt
ln -s ../apix.sh
sh apix.sh
cal_fsc.sh startingapix_0001.pdb apix_refined.mrc $4 &
cal_fsc.sh starting.pdb map.mrc $4 &
mkdir localrlx
cd localrlx
ln -s ../starting_INPUTapix_0001.pdb starting.pdb
ln -s ../apix_refined.mrc
ln -s ../../localrlx.xml
ln -s ../../localrlx.sh
$rosetta/source/src/apps/public/symmetry/make_symmdef_file.pl $3 -r 1000 -p starting.pdb  >symm_def.txt
modify_sym_def.pl symm_def.txt
parallel -j16 ./localrlx.sh {} ::: {1..16}
exit 0
cal_molprob.sh
cd localrlx
grep 'FSC' starting_INPUTlocalrlx_*pdb | sed 's/:/ /' | awk '{print $1,$6;}' | sort -nk 2 >fsc.txt
parse_molpro_fsc.pl all_molprob_results.txt fsc.txt >all_molpro_fsc

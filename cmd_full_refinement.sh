#!/bin/bash
if [ $# -lt 4 ]; then
	echo "Usage: $0 <full_map_file> <sdf_options> <resolution> <weight>"
	echo "Eg.: $0 1.mrc '-m NCS -a A -i B H' 3.3 35"
	echo "Make sure you have symmetry defintion option, flags file and xml file set up correctly"
	exit 1
fi
echo "$0 $1 $2 $3 $4"
cp /gscratch/baker/binchen/EM-data_challenge/xmls/flags flags_template 
cp /gscratch/baker/binchen/EM-data_challenge/xmls/localrlx_2.xml localrlx.xml 
sed "s/resx/$3/;s/weight/$4/" flags_template >flags
if [ ! -s fsc_top200/top10_fsc_fullmap.txt ]; then
	if [ ! -d fsc_top200 ]; then
		for pdb in `ls *pdb`; do fsc=`head -n1 $pdb | awk '{print $NF;}'`; echo $pdb $fsc >>all_fsc.txt; done;
		cat all_fsc.txt | sort -r -nk 2 | head -n 200 | cut -d' ' -f1 >fsc_top200.txt
		mkdir fsc_top200
		cat fsc_top200.txt | xargs -i mv {} fsc_top200
		rm *pdb
		cal_molprob.sh
	fi
	cat fsc_top200/all_molprob_results.txt | sed '1 d' | awk 'NF>1' | sed '/^$/d' | sort -nk 4 | head -n 50 >top50_molpro.txt
	cat top50_molpro.txt | awk '{print $1;}' | sed 's/A_molprob.log/.pdb/' | sed 's/^/cal_fsc.sh /' | sed "s|$| ../$1 $3|" >fsc_top200/cal_fsc.sh
	cd fsc_top200
	cat cal_fsc.sh | parallel -j16 
	tail -n1 *fsc.txt | sort -nk 3 | tail -n10 | awk '{print $1;}' | sed 's!RSCC/FSC/FSCmask:!!' >top10_fsc_fullmap.txt
	cd ..
fi
for pdb in `cat fsc_top200/top10_fsc_fullmap.txt | sed 's/.pdb//'`;do
  mkdir $pdb
  cd $pdb
  ln -s ../fsc_top200/$pdb\.pdb
   $rosetta/source/src/apps/public/symmetry/make_symmdef_file.pl $2 -r 1000 -p $pdb\.pdb  >symm_def.txt
   modify_sym_def.pl symm_def.txt
  ln -s ../$1 map.mrc
  ln -s ../localrlx.xml
  ln -s ../flags
  if [ ! -f run.lock ]; then
    touch run.lock
    nohup /gscratch/baker/binchen/bin/rosetta_scripts.static.linuxgccrelease @flags -database /gscratch/dimaio/dimaio/Rosetta/database -in:file:s $pdb\_INPUT.pdb -mute all &
  fi
  cd ..
 done;
exit 0
cal_molpro.sh
for path in `cat fsc_top200/top10_fsc_fullmap.txt | sed 's/.pdb//'`;do
  cd $path
  for pdb in `ls ${path}_INPUT_*[^A].pdb`; do 
	fsc=`head -n1 $pdb | awk '{print $NF;}'`
	base=`basename $pdb .pdb`
	molpro=`grep $base all_molprob_results.txt | awk '{print $3,$4}'`
	 echo $pdb $fsc $molpro>>../all_fsc_refined_fullmap.txt; done;
  cd ..
done;

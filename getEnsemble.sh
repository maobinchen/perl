perl /work/binchen/bin/scripts/rosetta/rosetta3/extractLowScoreDecoys.pl default.out 10 top10.out
/work/robetta/src/rosetta/rosetta_source/bin/extract_pdbs.linuxgccrelease -in:file:silent top10.out -database /work/robetta/src/rosetta/rosetta_database -in:file:silent_struct_type binary
perl /work/binchen/bin/scripts/Util/mergePDB.pl -d . -kw S

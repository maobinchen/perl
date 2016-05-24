#!/usr/bin/env perl
use strict;
use warnings;

die("Usage: $0 <start_pdb> <map> <test_map> <resolution> <symmetry_def_file> <xml_file>\n") if(scalar @ARGV < 6);
my ($start_pdb,$map,$testmap,$reso,$symmdef,$xml) = @ARGV;
my @fa_wts = (25,35,50,70,100);
my @cen_wts = (10,15,25,40,60);
my $n_rep = 3;

my $app = "/gscratch/baker/binchen/EM-data_challenge/rosetta_scripts.static.linuxgccrelease";
my $flags = "-database /gscratch/baker/binchen/EM-data_challenge/database -parser:protocol ../$xml -ignore_unrecognized_res -score_symm_complex false -default_max_cycles 200 -edensity::cryoem_scatterers -crystal_refine -nstruct 10";
for (my $i=0; $i<5; $i++){
    my $kw = $fa_wts[$i]."_".$cen_wts[$i];
    print $kw,"\n";
    rmdir($kw) if(-d $kw);
    mkdir $kw;
    chdir $kw;
    #system("sh ../linked_it.sh");
    open(F,">run.sh");
    for (my $x=1; $x<=$n_rep; $x++){
	my $line = $app;
	$line .= " $flags";
	$line .= " -in:file:s ../$start_pdb";
	$line .= " -parser:script_vars map=../$map testmap=../$testmap symmdef=../$symmdef res=$reso fa_wt=$fa_wts[$i] cen_wt=$cen_wts[$i]";
	$line .= " -edensity::mapreso $reso";
	$line .= " -mute all";
	$line .= " -out::suffix _${kw}_$x >log_${kw}_$x\n";
	print F $line;
    } 
    close F;
    chdir("..");
}


#!/usr/bin/env perl
use strict;
use warnings;

my $folder = $ARGV[0];
die("Usage:$0 <pdbs_folder>\n$folder not exist:$!") unless(-d $folder);
opendir(D,$folder);
my @files = grep(/pdb$/,readdir(D));
chdir(D);
system("cp /work/binchen/design/inputs/* .") && die("can't copy input file:$!");
open(O,'>cmd');
foreach my $f (@files){
    my $kw = $1 if($f =~ /(.*)\.pdb$/);
    system("/work/binchen/bin/getBluePrint.pl $f") && die("failed to get blueprint:$!");
    system("mv default.blueprint $kw\.bp");
    system("/work/binchen/bin/getResfileFromBp.pl $kw\.bp") && die("failed to get resfile from $kw\.bp:$!"); #will generate signal file err unless all the loops are two residue hairpin with ABEGO type BEAB, BGGB, BAAB
    system("mv resfile $kw\.resfile");
    if(-e 'err'){
	system("rm err");
    }else{
	print O "/gscratch/baker/binchen/bin/rosetta_scripts.static.linuxgccrelease \@flags_barrel_design -mute core.io.database -mute core.io -mute all -in:file:s $f -parser:script_vars kw=$kw\n";
    }
}
close O;


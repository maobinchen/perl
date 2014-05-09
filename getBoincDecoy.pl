#!/usr/bin/env perl
use strict;
use warnings;

my $out_path = '/net/BOINC/results/';
my ($pn,$decoy) = ($ARGV[0],$ARGV[1]);
my $pn_8 = substr($pn,0,8);
my $ff = "$pn\_fold_SAVE_ALL_OUT_\*.all.out.bz2";
system("cp $out_path/$pn_8/$ff fold.out.bz2") && die("$out_path/$pn_8/$ff not exist");
system("bzip2 -d fold.out.bz2");
system("~/bin/getPDBFromSilent.pl fold.out $decoy");
system("mv $decoy\.pdb $pn\_$decoy\.pdb");
system("rm fold.out");



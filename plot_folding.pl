#!/usr/bin/env perl
use strict;
use warnings;

my $out_path = '/net/BOINC/results/';
my $pn = $ARGV[0];
my $pn_8 = substr($pn,0,8);
my $id = $ARGV[1] or '';
my $ff = "$pn\_fold_SAVE_ALL_OUT_$id\*.sc.bz2";
my $rf = "$pn\_relax_SAVE_ALL_OUT_$id\*.sc.bz2";
system("cp $out_path/$pn_8/$ff fold.sc.bz2") && die("$out_path/$pn_8/$ff not exist:$!");
system("cp $out_path/$pn_8/$rf relax.sc.bz2");
system("bzip2 -d fold.sc.bz2");
system("bzip2 -d relax.sc.bz2");
my $ff_o = $pn."_fold.sc";
my $rf_o = $pn."_relax.sc";
convert_f('fold.sc',$ff_o);
convert_f('relax.sc',$rf_o);
system("~/bin/plotFold.R $pn");
system("rm fold.sc relax.sc");


sub convert_f{
    my ($file,$out_f) = @_;
    open(F,$file);
    open(O,">$out_f");
    while(<F>){
	next if(/W\_.*$/);
	if(/description$/){
	    chomp;
	    $_ .= "\t\t\tindex\n";
	}elsif(/^SEQ/){
	    next;
	}	
	print O $_ unless(/FAILURE/);	
    }
}



#!/usr/bin/env perl
use strict;
use warnings;

my $dssp_bin = '~/bin/dssp';
die("Usage: $0 <pdb_file>\n") unless(-e $ARGV[0]); 
my $pdb_f = $ARGV[0];
system("$dssp_bin $pdb_f >dssp.out") && die("can't run dssp:$!");
open(F,'dssp.out');
open(O,">pair.dat");
my $cutoff = -1.5;
my $flag=0; 
while(<F>){
    if($flag){
	my $resi = int(substr($_,5,5));
	my $p1 = substr($_,42,8);
	my ($hb1,$shift1);
	if($p1 =~ /(\-?\d+),(\-\d+\.\d+)/){
	    ($shift1,$hb1) = ($1,$2);
	}
	my $p2 = substr($_,53,8);	
	my ($hb2,$shift2);
	if($p2 =~ /(\-?\d+),\s*(\-?\d+\.\d+)/){
	    ($shift2,$hb2) = ($1,$2);
	}
	my $ori = 1; #default orientation anti
	if($hb2<=$cutoff && $hb1 <= $cutoff){
	    #$ori = 2 if($shift1 != $shift2); #change orientation to 1 if pair with different residue
	    if($shift1 == $shift2){
		    my $bpi = $resi + $shift1;
		    print O "$resi $bpi $ori 2\n";
	    }	
	}
    }else{
	$flag = 1 if(/^\s*#\s+RESIDUE/);
    } 
}
close F;
close O;

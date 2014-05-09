#!/usr/bin/env perl
use strict;
use warnings;

my $bp_file = $ARGV[0];
open(B,$bp_file) or die("failed to open blueprint file:$!");
my $lb = 4.0;
my $ub = 5.6;
my $tol = 0.3;
open(O,'>ca.cst') or die("can't create ca.cst:$!");
my $in = 0;
while(<B>){
    if($in){
	if(/(\d+)\-(\d+)\.(\d+)\-(\d+)/){
	    my ($s1,$e1,$s2,$e2) = ($1,$2,$3,$4);
	    my $nres1 = $e1-$s1+1;
	    my $nres2 = $s2-$e2+1;
	    if($nres1 ne $nres2){
		print("strand pair not equal:$_");
	    }else{ 
		for(my $i=0;$i<$nres1;$i++){
		    my $res1 = $s1+$i;
		    my $res2 = $s2-$i;
		    print O "AtomPair CA $res1 CA $res2 BOUNDED 4.0 $ub $tol\n";
		}
	    }
	}elsif(/^SSPAIR/){
	    last;
	}	
    }
    if(/^#### StrandPairingSet Info/){
	$in = 1; 
    }
}
close O;
close B;


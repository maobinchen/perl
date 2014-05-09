#!/usr/bin/env perl
use strict;
use warnings;

#the median and mad differences are based on 10 NESG NMR structures with high structural similarity with corresponding X-ray structures:BeR31,CcR55,DhR29B,HR41,HR3102A,HR6494F,SrR115C,XcR50,PfR193A,MrR110B
my %median = (0=>0,1=>0.3,2=>0.55,3=>0.895,4=>1.255,5=>1.6,6=>2.13,7=>2.63,8=>3.82,9=>4.11,10=>5);
my %mad = (0=>0.3,1=>0.3,2=>0.5,3=>0.7,4=>0.96,5=>1.25,6=>1.69,7=>1.94,8=>2.13,9=>2.49,10=>2.8);
die("Usage: $0 <rosetta_restraints_file>\n") if(scalar @ARGV < 1);
my $cst_f = $ARGV[0];

open(F,$cst_f);
my %cst = ();
while(<F>){
   if(/^(AtomPair|AmbiguousNMRDistance)/){
        my @values = split(/\s+/,$_);
        my ($dis1,$dis2);
        my ($atom1,$res1,$atom2,$res2,$lol,$upl) = ($values[1],$values[2],$values[3],$values[4],$values[6],$values[7]);
	next if(abs($res1-$res2)<5); #keep long distance constraints only
        ($atom1,$dis1) = @{&pmap($atom1)};
        ($atom2,$dis2) = @{&pmap($atom2)};
	my $kw = '';
	if($res1<$res2){
	    $kw = "$res1$atom1-$res2$atom2";
	}else{
	    $kw = "$res2$atom2-$res1$atom1";
	}
        my $bd = $dis1 + $dis2; #total number of bonds between two prtons
	my $upl_m = $upl+$median{$bd};
	my $var_m = $mad{$bd};
	my $res_s= sprintf("AtomPair %-4s %4d  %-4s %4d   BOUNDED   %.2f   %.2f   %.2f  NOE\n",$atom1,$res1,$atom2,$res2,$lol,$upl_m,$var_m); 
	if(defined $cst{$kw}){
	    if($upl_m+$var_m < $cst{$kw}->{upl}){
		$cst{$kw}->{str} = $res_s;
		$cst{$kw}->{upl} = $upl_m+$var_m;
	    }
	}else{
	    $cst{$kw}->{str} = $res_s;
	    $cst{$kw}->{upl} = $upl_m+$var_m;
	}
    }
}
close F;

open(O,">CACB_$cst_f");
foreach (sort keys %cst){
    print O $cst{$_}->{str};
}
close O;

sub pmap{
    my $atom = shift;
    my ($mapA,$dis);
    if($atom eq 'H'){
        $mapA = 'H';$dis = 0;
    }elsif($atom =~ /A/){
        $mapA = 'CA';$dis = 1;
    }elsif($atom =~ /B/){
        $mapA = 'CB';$dis = 1;
    }elsif($atom =~ /G/){
        $mapA = 'CB';$dis = 2;
    }elsif($atom =~ /D/){
        $mapA = 'CB';$dis = 3;
    }elsif($atom =~ /E/){
        $mapA = 'CB';$dis = 4;
    }elsif($atom =~ /H/){
        $mapA = 'CB';$dis = 5;
    }else{
        $mapA = $atom;$dis=0;
    }
    return [$mapA,$dis];
}

1;

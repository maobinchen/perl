#!/usr/bin/env perl 
use strict;
use warnings;

my ($cst_f,$coor_f) = @ARGV;
my $min_res_sep = 5;
open(C,$coor_f);
my %coor = ();
while(<C>){
    if(/^ATOM/){
	my $atom_n = substr($_,12,4);
	$atom_n =~ s/\s//g;
	my $res_i =  int(substr($_,22,4));
	my $x = float(substr($_,30,8));
	my $y = float(substr($_,38,8));
	my $z = float(substr($_,46,8));
	$coor{$res_i}->{$atom_n} = [$x,$y,$z];
    }
}
close C;
 
my %cst = ();
my %contact = (); #residue contacts
my %diff = ();
open(F,$cst_f);
open(O,">upldiff.txt");
while(<F>){
   if(/^(AtomPair|AmbiguousNMRDistance)/){
	my @values = split(/\s+/,$_);
	my ($dis1,$dis2);
	my ($atom1,$res1,$atom2,$res2,$upl) = ($values[1],$values[2],$values[3],$values[4],$values[7]);
	next unless(abs($res1-$res2)>=$min_res_sep);
	($atom1,$dis1) = @{&pmap($atom1)};
	($atom2,$dis2) = @{&pmap($atom2)};
	unless($coor{$res1}->{$atom1}){
	    print $res1,$atom1,"\n"; 
	    print $_,"\n";
	    next;
	}
	unless($coor{$res2}->{$atom2}){
	    print $res2,$atom2,"\n" ;
	    print $_,"\n";
	    next;
	}
	my $coor_dis = &dist($coor{$res1}->{$atom1},$coor{$res2}->{$atom2});
	my $diff_a = $coor_dis-$upl;
	my $bd = $dis1 + $dis2; #total number of bonds between two prtons
	push(@{$diff{$bd}},$diff_a);	
	print O "$bd\t$diff_a\n";
    }	
}
close O;
close F;
sub dist{
    my ($coor1,$coor2) = @_;
    my $sum = 0;
    for (my $i=0;$i<3;$i++){
	$sum += ($coor1->[$i]-$coor2->[$i])**2;
    }
    my $dis = sqrt($sum);
    return $dis;
}

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

sub float{
    my $v = shift;
    return sprintf("%8.3f",$v);
}

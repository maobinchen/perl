#!/usr/bin/env perl
use strict;
use warnings;
#BAAB NNDDST PPE DDDNST G  
#BEAB YYVHSF G  NDS TTGNRFK
#BGGB YYHHIV NNHHDG G KKNREQ
my $err_f = 'err';
open(L,">>log");
my %haripin = ( 'BGGB' => ['YYH','NNHHDG','G','KKNREQ'],
                'BEAB' => ['YYHS','G','NDS','TTGNRK'],
                'EEAE' => ['YYHS','G','NDS','TTGNRK'],
                'EEAB' => ['YYHS','G','NDS','TTGNRK'],
		'BAAB' => ['NNDDST','PPE','DDDNST','G'],
		'BBGB' => ['AGKLRSVEFV','PPPEK','G','IKLGRV']);
my $b_str = 'IITTVVYYWWFFCMQSRL';
my $bp_f = $ARGV[0];
my %bp = ();
open(F,$bp_f) or die("Usage: $0 <blueprint_file>\n");
while(<F>){
    if(/^\d+/){
	chomp;
	my @values = split(/\s+/,$_);
	my $resi = $values[0];
	$bp{$resi} = $values[2];
    }
}
close F;
open(O,">resfile");
print O "start\n";
my %ss4 = ();#secondary structure
my %abego4 = ();#ABEGO type
my $nres = scalar keys %bp;
for (my $resi=1; $resi<=$nres-3; $resi++){ 
   $ss4{$resi} = '';
   $abego4{$resi} = '';
   for (my $j=0;$j<4;$j++){
	my $cur_res = $resi+$j;
	$ss4{$resi} .= substr($bp{$cur_res},0,1);
	$abego4{$resi} .= substr($bp{$cur_res},1,1);
    }   
    if($ss4{$resi} =~ /^LLL/){
	print L "Loop longer than 2 started at $resi for $bp_f\n"	if($ss4{$resi-1} =~ /^L/);
#	system("touch $err_f");
    }
} 
for (my $resi=1; $resi<=$nres-1; $resi++){
   if ($ss4{$resi} && $ss4{$resi} eq 'ELLE'){ #identify hairpin
	if($haripin{$abego4{$resi}}){
		for (my $j=0;$j<4;$j++){
		     my $cur_res = $resi+$j; 
		    print O "$cur_res A PIKAA $haripin{$abego4{$resi}}->[$j]\n";
		}
	}else{
	    print L "Abego type at $resi for $bp_f unusual for $bp_f\n"; 
	    system("touch $err_f") unless(-e $err_f);
	}
	$resi += 3;
   }elsif($bp{$resi} eq 'EB'){
	print O "$resi A PIKAA $b_str\n";
    }
}
close O;

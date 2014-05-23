#!/usr/bin/env perl 
#this script is used to sample the long loops,allow at most two long loops
#input configuration file, include the loop start, shift, extension (beta strand),  loop end, shift , extension
#config file format: (resi(N) residue_shift_sample strand_extension_sample resi(C) residue_shift_sample strand_extension_sample)\d+\s+\d+:\d+\s+\d+\s+\d+:\d+\d+
#                    at most two gaps can be defined
use strict;
use warnings;

my($pdb_f,$cfg_f) = @ARGV;
my $remodel_app  = '/work/binchen/Rosetta/main/source/bin/remodel.default.linuxgccrelease';
my $lh_opts = '-lh:db_path /work/binchen/db/3to25mer/ -lh_ex_limit 8 -lh:max_radius 10 -use_loop_hash';
my $n_str = 10;
my $rosetta_db = '/work/binchen/Rosetta/main/database/';
my $opts = "-nstruct $n_str -database $rosetta_db -num_trajectory 1 -remodel:use_cart_relax -remodel:free_relax -ss_pair 1.0 -rsigma 1.0 -hb_lrbb 1.5";
my $remodel_cmd = "$remodel_app -s $pdb_f $opts";
my $lh_f = 0;
$remodel_cmd .= " $lh_opts" if($lh_f);
my @loop_range = (3,5);
unless(-e $pdb_f and -e $cfg_f){
    die("Usage: $0 <pdb_f> <config_file>\n");
}
system("/work/binchen/bin/getBluePrint.pl $pdb_f") && die("can't get blueprint for $pdb_f:$!");
my %bp = ();
open(F,'default.blueprint'); 
while(<F>){
    if(/^\d+/){
        chomp;
        my @values = split(/\s+/,$_);
        my $resi = $values[0];
        $bp{$resi}->{aa} = $values[1];
        $bp{$resi}->{ss} = substr($values[2],0,1);
    }
}
close F;
my @lpos = (); #holding residue index of loops termini
my @lbps  = (); #holding position to be remodeled
my @ins = (); #inserted elements 

open(C,$cfg_f);
my $i = 0;
while(<C>){
    if(/\d+/){
	chomp;
	my @values = split(/\s+/,$_);
	if(scalar @values == 6){
		my @range1 = split(/:/,$values[1]);
		my @range2 = split(/:/,$values[4]);
		for (my $s = $range1[0]; $s <= $range1[1];$s++){
		    my $sp = $values[0]+$s; #position of N-termini of loop i
		    for (my $e = $range2[0]; $e <= $range2[1];$e++){
			my $ep = $values[3]+$e; #position of C-termini of loop i
			push(@{$lpos[$i]},[$sp,$ep]);
		    }
                }
	        for(my $b=0;$b<=$values[2];$b++){	
		    my $bp_str = '';
		    my $is_s = '';
		    my $bs = reps("0 x E\n",$b);
		    my $is = '';
		    $is = $b."E" if($b>0);
		    for(my $ls = $loop_range[0];$ls<=$loop_range[1];$ls++){
			my $l1 = reps("0 x L\n",$ls);
			my $is1 = $ls."L";
			for(my $b1=0;$b1<=$values[5];$b1++){
			   $bp_str = $bs.$l1.reps("0 x E\n",$b1); 
			   my $is_e = '';
			   $is_e = $b1."E" if($b1>0);
			   $is_s = $is.$is1.$is_e;
			   push(@{$lbps[$i]},$bp_str);
			   push(@{$ins[$i]},$is_s);
			}
		    }
	        }
		$i++;
        }
    }
}
#system("rm *bp cmd");
for(my $i=0;$i<scalar @{$lpos[0]};$i++){
    if($lpos[1]){
	for(my $j=0;$j<scalar @{$lpos[1]};$j++){
	    generateBP($lpos[0]->[$i],$lpos[1]->[$j]);	    
	}
    }else{
	generateBP($lpos[0]->[$i],[10000,20000]);    
    }
}

sub generateBP{
    my ($n1,$n2,$n3); 
    my @l1 = ();
    my @l2 = ();
    my ($pos1,$pos2) = @_;    
    my $nres = scalar keys %bp;
    for(my $i=1;$i<=$nres;$i++){
	if($i<$pos1->[0]){
	    $n1 .= "$i $bp{$i}->{'aa'} .\n";
	}elsif($i == $pos1->[0]){
	    my $e = $pos1->[1];
	    foreach my $lbp (@{$lbps[0]}){
		push(@l1,"$i x E\n${lbp}$e x E\n");
	    }
	}elsif($i > $pos1->[1] and $i<$pos2->[0]){
	    $n2 .= "$i $bp{$i}->{'aa'} .\n";
	}elsif($i == $pos2->[0]){
              my $e2 = $pos2->[1];
              foreach my $lbp (@{$lbps[1]}){
                  push(@l2,"$i x E\n${lbp}$e2 x E\n");
              }
        }elsif($i > $pos2->[1]){
	    $n3 .= "$i $bp{$i}->{'aa'} .\n";
	}	
    }
    for(my $i=0;$i<scalar @l1;$i++){
	if(scalar @l2 > 0){
	    for(my $j=0;$j < scalar @l2;$j++){
		my $kw = $pos1->[0].$ins[0]->[$i].$pos1->[1].'-'.$pos2->[0].$ins[1]->[$j].$pos2->[1];
		open(F,">$kw\.bp");
		my $out_s = $n1.$l1[$i].$n2.$l2[$j].$n3;
		print F $out_s;
		close F;
		my $cmd =  "$remodel_cmd -remodel:blueprint $kw\.bp -out:user_tag $kw -out:suffix $kw -out:file:silent $kw.silent";
		system("echo $cmd >>remodel_cmd");
	    }
	}else{
	    my $kw = $pos1->[0].$ins[0]->[$i].$pos1->[1];
	    open(F,">$kw\.bp");
	    my $out_s = $n1.$l1[$i].$n2;
	    print F $out_s;
            close F;
            my $cmd =  "$remodel_cmd -remodel:blueprint $kw\.bp -out:user_tag $kw -out:suffix $kw -out:file:silent $kw.silent";
            system("echo $cmd >>remodel_cmd");
	}
    }
}

sub reps{
    my($s,$n) = @_;
    my $str = '';
    for(my $i=0;$i<$n;$i++){
	$str .= $s;
    }  
    return $str;
}
1;

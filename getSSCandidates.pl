#!/usr/bin/env perl
use strict;
use warnings;

my ($dir,$range1,$range2) = @ARGV;
my ($start1,$end1) = split('-',$range1);
my ($start2,$end2) = split('-',$range2);
opendir(D,$dir) or die("can't open directory $dir:$!");
my @pdbs = grep {/\.pdb$/} readdir(D);
chdir(D);
closedir(D);
open(O,'>ss_candidate');
print O "pdb\tres1\tres2\tca_dis\tcb_dis\n";
foreach (@pdbs){
    checkSS($_);
}
close O;
sub checkSS{
    my $pdb = shift;
    open(F,$pdb) or die("can't open $pdb:$!");
    my %coords = ();
    while(<F>){
	 if(/^ATOM/){
                my $i = int(substr($_,22,4));
		if(($start1<=$i && $i<=$end1) or ($start2<=$i && $i<=$end2)){
                    my $a = cc(substr($_,12,4));
		    next unless($a eq 'CA' or $a eq 'CB');
                    my $x1 = cc(substr($_,30,8));
                    my $y1 = cc(substr($_,38,8));
                    my $z1 =cc(substr($_,46,8));
		    $coords{$i}->{$a} = [$x1,$y1,$z1];
		}
	}
    }
    close F;
    my $min_ca_dis = 100;
    my $min_cb_dis = 100;
    for(my $i1=$start1;$i1<=$end1;$i1++){
	next unless($coords{$i1}->{CB});
	for (my $i2=$start2;$i2<=$end2;$i2++){
	    my $ca_dis = dis($coords{$i1}->{CA},$coords{$i2}->{CA});
	    next unless($coords{$i2}->{CB});
	    my $cb_dis = dis($coords{$i1}->{CB},$coords{$i2}->{CB});
	    if($ca_dis<=6.5 && $cb_dis<=4.5){
		 print O "$pdb\t$i1\t$i2\t$ca_dis\t$cb_dis\n";
	    }  
	    $min_ca_dis = $ca_dis if($ca_dis<$min_ca_dis);
	    $min_cb_dis = $cb_dis if($cb_dis<$min_cb_dis);
	}   
    }
    print "$pdb\nmin_ca_dis=$min_ca_dis\tmin_cb_dis=$min_cb_dis\n";
}

sub cc{
        my $v = shift;
        $v =~ s/^\s+//;
        $v =~ s/\s+$//;
        return $v;
}

sub dis{
    my ($p1,$p2)= @_;
    my ($x1,$y1,$z1) = @{$p1};
    my ($x2,$y2,$z2) = @{$p2};
    my $d1 = sqrt(($x1-$x2)**2+($y1-$y2)**2+($z1-$z2)**2);
    return $d1;
}

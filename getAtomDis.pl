#!/usr/bin/env perl
use strict;
use warnings;

die("Usage : $0 <dir> <res1-atom1> <res2-atom2>\n") if(scalar @ARGV < 3);
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
		my $a = cc(substr($_,12,4));
		if(($start1==$i && $a eq $end1) or ($start2==$i && $a eq $end2)){
                    my $x1 = cc(substr($_,30,8));
                    my $y1 = cc(substr($_,38,8));
                    my $z1 =cc(substr($_,46,8));
		    $coords{$i}->{$a} = [$x1,$y1,$z1];
		}
	}
    }
    close F;
    my $dist = dis($coords{$start1}->{$end1},$coords{$start2}->{$end2});
    print O "$pdb\t$dist\n";
    print $pdb,"\t$dist\n" if($dist < 3.2);
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

#!/usr/bin/env perl
use strict;
use warnings;

my $ref_pdb = $ARGV[0];
die("Usage: $0 <ref_pdb>") unless(-e $ref_pdb);
opendir(D,'.');
my @files = grep(/pdb$/,readdir(D));
my %info;
foreach my $f (@files){
    next if($f eq $ref_pdb);
    my $tm = `~/bin/scripts/Util/TMscore $f $ref_pdb | grep 'GDT-TS' | awk '{print \$2;}'`;
    chomp($tm);
    $info{$f} = $tm ;
}
foreach my $f (sort {$info{$b}<=>$info{$a}} keys %info){
    print $f,"\t",$info{$f},"\n";
}

#!/usr/bin/env perl
use strict;
use warnings;

my @pdbfs = @ARGV;
unless(@pdbfs){
    opendir(D,'.');
    @pdbfs = readdir(D);
}
open(L,'>pdblst');
foreach (@pdbfs){
    print L $_,"\n" if(/\.pdb$/);
}    
close L; 
my $cmd = '~/rosetta/rosetta_source/bin/score_jd2.linuxgccrelease -in:file:l pdblst -database ~/rosetta/rosetta_database/ -holes:dalphaball /work/sheffler/bin/DAlphaBall.gcc -score.weights ~/bin/score12_holes.wts -out:file:scorefile score_12.sc -mute all';
system($cmd);
system("rm pdblst");




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
    print L $_,"\n" if(/\.pdb$/);;
}    
close L;
my $cmd = '~/Rosetta/main/source/bin/score_jd2.default.linuxgccrelease -in:file:l pdblst -database ~/rosetta/rosetta_database/ -holes:dalphaball /work/sheffler/bin/DAlphaBall.gcc -score.weights ~/bin/talaris2013.wts -out:file:scorefile score1.sc';
system($cmd);
system("rm pdblst");




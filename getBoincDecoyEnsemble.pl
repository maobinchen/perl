#!/usr/bin/env perl
use strict;
use warnings;

my $out_path = '/net/BOINC/results/';
die("Usage: perl $0 <boinc_name> <boinc_id>") if(scalar @ARGV < 2);
my ($pn,$bi) = ($ARGV[0],$ARGV[1]);
my $n = 10;
$n = $ARGV[2] if($ARGV[2]);
my $pn_8 = substr($pn,0,8);
my $ff = "$pn\_$bi\_0.out.bz2";
my $sf = "$pn\_$bi\_0.sc.bz2";
system("cp $out_path/$pn_8/$ff fold.out.bz2") && die("$out_path/$pn_8/$ff not exist");
system("cp $out_path/$pn_8/$sf fold.sc.bz2") && die("$out_path/$pn_8/$sf not exist");
system("bzip2 -d fold.out.bz2");
system("bzip2 -d fold.sc.bz2");
my $outf = "top$n";
system("cat fold.sc | sort -n -k 2 |  awk '{print \$(NF-1);}' | grep '^S_' | head -n $n >$outf");
system("~/bin/getSilentByTags.pl fold.out $outf");
system("~/bin/getPDBFromSilent.pl $outf\.out _");
system("perl ~/bin/scripts/Util/mergePDB.pl  -d . -kw S_");
if(-e 'xray.pdb'){
    system("perl /work/binchen/bin/scripts/Util/comp_str_sim.pl xray.pdb ensemble.pdb str_cmp order");
}




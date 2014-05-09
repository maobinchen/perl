#!/usr/bin/env perl
use strict;
use warnings;

my ($silent_f,$tag_f) = @ARGV;
die("Usage: $0 <silent_f> <tag_f>\n") unless(-e $silent_f && scalar @ARGV == 2);
my $out_f = $tag_f.'.out';
system("head -n 2 $silent_f >head.out");
open(L,$tag_f);
foreach (<L>){
    chomp;
    s/\.pdb$//;
    my $tag = $_;
    system("grep $tag $silent_f >temp.out");
    system("cat head.out temp.out >>$out_f");
    system("rm temp.out");
}
close L;

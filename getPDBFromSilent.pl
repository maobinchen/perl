#!/usr/bin/env perl 
use strict;
use warnings;

my ($silent_f,$tag) = @ARGV;
die("Usage: $0 <silent_f> <tag>\n") unless(-e $silent_f && scalar @ARGV == 2);  
my $silent2pdb_app = '~/rosetta/rosetta_source/bin/extract_pdbs.linuxgccrelease';
my $rosetta_db = '~/rosetta/rosetta_database';
system("head -n 2 $silent_f >head.out");
system("grep $tag $silent_f >temp.out");
system("cat head.out temp.out >$tag\.out");
system("rm temp.out");
system("$silent2pdb_app -database $rosetta_db -in:file:silent $tag\.out -in:file:silent_struct_type binary -silent_read_through_errors");
system("rm $tag\.out");

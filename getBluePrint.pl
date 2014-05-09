#!/usr/bin/env perl
my $pdb_f = $ARGV[0];
die("Usage: $0 <pdb_f>") unless(-e $pdb_f);
system(" /work/binchen/Rosetta/main/source/bin/make_blueprint.default.linuxgccrelease -in:file:s $pdb_f -database ~/Rosetta/main/database/") && die("can't get blueprint from coords:$!");

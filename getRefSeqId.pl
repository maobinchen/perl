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
    system("~/bin/getPdbSeqId.pl $f $ref_pdb >id 2>/dev/null");
    open(I,"id");
    while(<I>){
	if(/^seq_id\=(\d+\.\d+)/){
	    $info{$f} = $1 ;
	}
    } 
    close I;
}
foreach my $f (sort {$info{$a}<=>$info{$b}} keys %info){
    print $f,"\t",$info{$f},"\n";
}

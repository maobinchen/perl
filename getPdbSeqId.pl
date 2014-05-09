#!/usr/bin/env perl
use strict;
use warnings;
die("Usage: $0 <pdb1> <pdb2>") if(scalar @ARGV < 2);
my ($pdb1,$pdb2) = @ARGV;
my $extract_fasta_script = '~/Rosetta/tools/perl_tools/getFastaFromCoords.pl';
my $bl2seq_path = '~robetta/src/shareware/blast-2.2.17_x64/blast-2.2.17/bin/bl2seq';
system("$extract_fasta_script -pdbfile $pdb1 >seq1") && die("failed to run $extract_fasta_script:$!");
system("$extract_fasta_script -pdbfile $pdb2 >seq2") && die("failed to run $extract_fasta_script:$!");
#system("$bl2seq_path -p blastp -i seq1 -j seq2 -F F") && die("can't run $bl2seq_path:$!");
my $seq1 = getSeq('seq1');
my $seq2 = getSeq('seq2');
my $n = length($seq1);
my $id = 0;
for(my $i=0;$i<$n;$i++){
   $id++ if(substr($seq1,$i,1) eq substr($seq2,$i,1));
}
my $seq_id = sprintf("%.3f",$id/$n);
print "\nseq_id=$seq_id ($id/$n)\n";

system("rm seq1 seq2");
sub getSeq{
    my $seq_f = shift;
    my $seq = '';
    open(S,$seq_f);
    while(<S>){
	next if(/^\>/);
	chomp;
	$seq .= $_;
    }
    close S;
    return $seq;
}

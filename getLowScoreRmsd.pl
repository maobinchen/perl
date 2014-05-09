#!/usr/bin/env perl
use strict;
use warnings;
if(-d "top10"){
    chdir("top10");
}else{
    mkdir("top10");
    chdir("top10");
    system("~/bin/extract_lowscore_decoys.py ../top100.out 20 >top10.out");
    system("~/bin/getPDBFromSilent.pl top10.out _");
    system("grep '^SCORE' top10.out >top10.sc");
}
open(T,'top10.sc');
my %info;
while(<T>){
    if(/^SCORE\:\s+(\-?\d+\.\d+).*(S\S+)$/){
	$info{$2}->{'score'} = $1;
    }
}

opendir(D,'.');
my @files = readdir(D);
open(O,">str_cmp");
print O "decoy\trms\tscore\tgdt-ts\t<1\t<2\t<4\t<8\n";
foreach (@files){
    if(/^(S.*)\.pdb$/){
	my $kw = $1;
	system("~/bin/scripts/Util/TMscore $_ ../00001.pdb >tm.out");
	open(T,"tm.out");
	while(<T>){
	    if(/^RMSD.*\=\s+([\d\.]+)/){
		$info{$kw}->{'rms'} = $1;
	    }elsif(/^GDT\-TS/){
		my @values = split(/\=\s*/,$_);
		foreach (@values){
		    push(@{$info{$kw}->{'gdt'}},$1) if(/(\d\.\d+)/);
		}
	    }	
	}	
	close T;
    }
}
my @decoys = sort {$info{$a}->{'score'} <=> $info{$b}->{'score'}} (keys %info); 
foreach my $kw (@decoys){
    my @values = ($kw,$info{$kw}->{'score'});
    push(@values,$info{$kw}->{'rms'});
    push(@values,@{$info{$kw}->{'gdt'}});
    print O join("\t",@values),"\n";
}
close O;
system("rm tm.out");





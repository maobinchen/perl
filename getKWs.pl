use strict;
use warnings;

my $file = shift @ARGV;
die("Usage $0 <file> <kw1> [kw2..]") unless(-e $file);
open(F,$file) or die("can't open file $file:$!");
open(O,">kws_$file") or die("can't open file kws_$file:$!");
my %head = ();
my $h = 0;
while(<F>){
   if($h){
	chomp;
	my @values = split(/\s+/,$_);
	if(scalar @values != $head{'n'}){
	    print $_,"\n";
	}else{
	    my @vs = ();
	    foreach (@{$head{'cols'}}){
		push(@vs,$values[$_]);
	    }
	    print O join("\t",@vs),"\n";
	}
   }else{
	chomp;
	my @kws = split(/\s+/,$_);
	$head{'n'} = scalar @kws;
	foreach my $kw (@ARGV){
	    my $i=0;
	    foreach (@kws){
		if($_ eq $kw){
		    push(@{$head{'cols'}},$i);
		    last;
		}
		$i += 1;
	    }    
	}
	print O join("\t",@ARGV),"\n";
	$h=1;
   }
}
close F;
close O;

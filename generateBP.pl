use strict;
use warnings;

my ($bp_file,$flag_f,$l1) = @ARGV;
my $min=4;
my $max=12;

open(B,$bp_file);
my @strs = ();
for (my $j=0;$j<3;$j++){
    push(@strs,'');
}
my $i = 0;
while(<B>){
   my @values = split(/\s+/,$_);
   my $res_i = shift @values;
   if($res_i > 0){
	if($res_i>$l1){
	    $i=1;
	}
   }   
   $strs[$i] .= $_;
}
close B;
my $flag_s = '';
open(F,$flag_f);
while(<F>){
    next if(/lh_filter_string/);
    next if(/remodel\:blueprint/);
    $flag_s .= $_ unless(/^#/);
}
close F;
open(R,">run");
    for(my $j = $min;$j<=$max;$j++){
	 my $j_str = '';
	my $j_fil = '??';
	for (my $x=0;$x<$j;$x++){
            $j_str .= "0 x L\n";
	    if($j<=5 or $x<=1 or ($j-$x)<=2){
		$j_fil .= '?';
            }else{
	        $j_fil .= 'A';
            }
	 }
	$j_fil .= '?';
	my $bp_fo = "r3_$j\.bp";
	open(O,">$bp_fo");
	my $out_s = $strs[0].$j_str.$strs[1];
	print O $out_s;
	close O;
	my $flag_fo = "flag_$j";
	open(S,">$flag_fo");
	print S "$flag_s";
	print S "-remodel:blueprint $bp_fo\n";
	print S "-lh_filter_string $j_fil\n"; 
	close S;
	print R "/work/binchen/bin/rmdl_new.test3 \@$flag_fo -out:suffix _$j -out:file:silent remodel_$j\.out\n";
    }
close R;

#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;

my $dir = $ARGV[0];
die("Usage: $0 <pdbs_folder> [decoy_file]") unless(-d $dir);
my $decoy_f = $ARGV[1] or '';
my @decoys = ();
if(-e $decoy_f){
    open(F,$decoy_f);
    while(<F>){
	chomp;
	push(@decoys,"$_\.pdb");
    }
    close F;
}
unless(scalar @decoys > 0){
    opendir(D,$dir);
    @decoys = grep(/\.pdb/, readdir(D));
}
chdir($dir);
my $path = getcwd;
my $n_str = scalar @decoys;
my $n_proc = 10;
system("/work/binchen/bin/digload >loaddig");
my @digs = ();
open(F,"loaddig");
while(<F>){
    my @values = split(/\s+/,$_);
    if($values[2]<15){
	push(@digs,$values[0]) unless($values[0] eq 'dig1' or $values[0] eq 'dig2' or $values[0]=~/big/);
    }else{
	last;
    }
}
my $n_batch = int(($n_str-0.1)/$n_proc)+1;
for(my $i=0;$i<$n_batch;$i++){
    next if(-e "cmd$i\.sh");
    my $cmd = '/work/binchen/bin/make_fragments.py -pdbs';
    my $pdbs = '';
    for (my $j=0;$j< $n_proc;$j++){
	my $ind = $i*$n_proc+$j;
	last if($ind >= $n_str);
	$pdbs .= " $decoys[$ind]";	
    }
    $cmd .= $pdbs; 
    open(S,">cmd$i\.sh");
    print S "cd $path\n$cmd\&\nexit\n";
    close S;
    system("chmod +x cmd$i\.sh");
#    system("cp cmd$i\.sh ~"); 
#    system("chmod +x cmd$i\.sh");
    if (fork() == 0) {
	my $cur_dig = $digs[$i];
	print "submit $path/cmd$i\.sh to $cur_dig\n";
	system("ssh $cur_dig $path/cmd$i\.sh"); 
	exit;
    }
}


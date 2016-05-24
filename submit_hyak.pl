use strict;
use warnings;
use Cwd;
my %opts;
my $pwd = getcwd();
my $exec = '/gscratch/baker/binchen/bin/minirosetta.static.linuxgccrelease';
#my $rosetta_db = '/gscratch/baker/grocklin/Rosetta/main/database/';
my $rosetta_db = '/gscratch/baker/binchen/database/';
my $args = "-database $rosetta_db ";
my $name = "unknown";
my $nnodes = 1;
my $bf_s = '';
my $ncpu = 12;
my $nstr = 100; 
my @cmds = ();
my %core_asa = ();
my %surface_asa = ();
for(my $i=1;$i<=$ncpu;$i++){
	if($i < $ncpu/3+0.1){
		$core_asa{$i} = 25;
		$surface_asa{$i} = 40;
	}elsif($i < 2*$ncpu/3+0.1){
		$core_asa{$i} = 30;
		$surface_asa{$i} = 45;
	}else{
		$core_asa{$i} = 35;
		$surface_asa{$i} = 50;
	}
}
%opts = &getOptions();
if($opts{cmdfile}){
	open(F,$opts{cmdfile}) or die("can't open file $opts{cmdfile}:$!");
	while(<F>){
		chomp;
		s/^\s+//;
		unless(/\-parser\:script_vars/){
			$_ .= " -parser:script_vars";	
		}
		push(@cmds,$_);	
	#	last;
	}
	close F;
}elsif(defined $opts{args}){
	$exec = $opts{exec} if($opts{exec});
	$args .= $opts{args};
	$cmds[0] = "$exec $args";
}else{
	die("Usage: $0 [-cmdfile command_file] <nnode number_of_nodes> <name proj_name> <-exec executable> <-args arguments> <-bf>\n");
}

my $n_cmds = scalar @cmds;
$nnodes = $opts{nnodes} if($opts{nnodes});
$name = $opts{name} if($opts{name});
my $wall_time = '48:00:00';
$wall_time = '2:30:00' if($opts{bf});
$bf_s = '-q bf' if($opts{bf});


for(my $k=0;$k<$n_cmds;$k++){
    for(my $i=1;$i<=$nnodes;$i++){
	my $fn = "$name\_$k\_$i";
	open(C,">cmds_$fn") or die("can't open file cmds_$fn:$!");
	for(my $j=1;$j<=$ncpu;$j++){
	        #print C "$cmd -database $rosetta_db -nstruct $nstr -out:file:silent $fn\_$j.out -out:suffix _$i\_$j -user_tag _$i\_$j\n";
	        print C "$cmds[$k] core_asa=$core_asa{$j} surface_asa=$surface_asa{$j} -database $rosetta_db -out:file:silent $fn\_$j.out -out:suffix _$i\_$j -user_tag _$i\_$j\n";
	}
	close C;
	open(O,">$fn.sh") or die("can't create file $fn.sh:$!");
	print O "#!/bin/bash\n";
	print O "#PBS -N $name\_$i\n";
	print O "#PBS -l nodes=1:ppn=12,mem=22gb,feature=12core,walltime=$wall_time\n";
	print O "#PBS -o $pwd\n";
	print O "#PBS -d $pwd\n";
	print O "#PBS -j oe\n\n";
	print O "cd $pwd;cat cmds_$fn | parallel -j$ncpu\n";
	close O;
	system("qsub $bf_s $fn.sh") && die("can't submit $fn.sh:$!");
    }
}

sub getOptions{
    use Getopt::Long;
    my %opts;
    &GetOptions(
        \%opts,
	"cmdfile=s",
        "exec=s",
        "args=s",
	"nnodes=i",
	"name=s",
	"bf!",
    );
    return %opts;
}

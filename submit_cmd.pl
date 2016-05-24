use strict;
use warnings;
use Cwd;
use POSIX; 
my %opts;
my $pwd = getcwd();
my $exec = '/gscratch/baker/binchen/bin/minirosetta.static.linuxgccrelease';
#my $rosetta_db = '/gscratch/baker/grocklin/Rosetta/main/database/';
my $rosetta_db = '/gscratch/baker/binchen/database/';
my $args = "-database $rosetta_db ";
my $name = "unknown";
my $bf_s = '';
my $ncpu = 12;
my $n_batch = 1; #the number of jobs running on a single node
my $n_node = 10; #number of nodes 
my $nrep = 1; #the number of repeatition for each cmd
my $nstr = 100; 
my $start = 0;
my @cmds = ();
#@surface_asa = (40,40,45);
%opts = &getOptions();
$n_batch *= $ncpu;
if($opts{cmdfile}){
	open(F,$opts{cmdfile}) or die("can't open file $opts{cmdfile}:$!");
	while(<F>){
		chomp;
		s/^\s+//;
		push(@cmds,$_);	
	#	last;
	}
	close F;
}else{
	die("Usage: $0 [-cmdfile command_file] <-nrep number_of_repeats_for_each_command> <-nnode number_of_nodes> <-name proj_name> <-bf>\n");
}

my $n_cmds = scalar @cmds;
$name = $opts{name} if($opts{name});
$nrep = $opts{nrep} if($opts{nrep});
$start = $opts{start} if($opts{start});
my $njobs = $n_cmds*$nrep;
$n_node = $opts{nnode} if($opts{nnode});
my $job_per_node = ceil($njobs/$n_node); 
$n_batch = $job_per_node if($job_per_node>$n_batch);
my $wall_time = '48:00:00';
$wall_time = '2:30:00' if($opts{bf});
$bf_s = '-q bf' if($opts{bf});

my $ind=0;
my @run_str = ();
for(my $k=0;$k<$n_cmds;$k++){
	for(my $j=0;$j<$nrep;$j++){
		my $fn = "$name\_$k\_$j";
		my $node_i = int($ind/$n_batch);
		my $suffix = $j+12*$start;
        #	$run_str[$node_i] .= "$cmds[$k] -out:file:silent $fn\.out -out:suffix _$j -user_tag _$j\n";
       		$run_str[$node_i] .= "$cmds[$k] -out:suffix _$suffix -user_tag _$suffix\n";
		$ind++;
	}
}

for(my $i=0;$i<scalar @run_str;$i++){
	my $fi = $i+$start;
	my $fn = "$name\_$fi";
	open(F,">cmds_$fn");
	print F $run_str[$i];
	close F;
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

sub getOptions{
    use Getopt::Long;
    my %opts;
    &GetOptions(
        \%opts,
	"cmdfile=s",
	"nrep=i",
	"nnode=i",
	"name=s",
	"start=i",
	"asa!",
	"bf!",
    );
    return %opts;
}

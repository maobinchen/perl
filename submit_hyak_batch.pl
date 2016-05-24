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
my $asa = 0;
my $ncpu = 12;
my $n_batch = 1; #the number of jobs running on a single node
my $n_node = 10; #number of nodes 
my $nrep = 1; #the number of repeatition for each cmd
my $nstr = 100; 
my @cmds = ();
my @core_asa = (25,30,35);
#@core_asa = (20,25,25);
my @surface_asa = (40,45,50);
#@surface_asa = (40,40,45);
%opts = &getOptions();
$n_batch *= $ncpu;
$asa = $opts{asa};
if($opts{cmdfile}){
	open(F,$opts{cmdfile}) or die("can't open file $opts{cmdfile}:$!");
	while(<F>){
		chomp;
		s/^\s+//;
		if($asa){
			unless(/\-parser\:script_vars/){
				$_ .= " -parser:script_vars";	
			}
		}
		push(@cmds,$_);	
	#	last;
	}
	close F;
}else{
	die("Usage: $0 [-cmdfile command_file] <-nrep number_of_repeats_for_each_command> <-nnode number_of_nodes> <-name proj_name> <-asa> <-bf>\n");
}

my $n_cmds = scalar @cmds;
$name = $opts{name} if($opts{name});
$nrep = $opts{nrep} if($opts{nrep});
my $njobs = $n_cmds*$nrep;
$njobs *= 3 if($asa);
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
		if($asa){ #sample different asa cutoff
			for(my $s=0;$s<scalar @core_asa;$s++){
				my $node_i = int($ind/$n_batch); 
				$run_str[$node_i] .= "$cmds[$k] core_asa=$core_asa[$s] surface_asa=$surface_asa[$s] -database $rosetta_db -out:file:silent $fn\_$s.out -out:suffix _$j\_$s -user_tag _$j\_$s\n";
				$ind++;
			}
		}else{
			my $node_i = int($ind/$n_batch);
        		$run_str[$node_i] .= "$cmds[$k] core_asa=35 surface_asa=50 -database $rosetta_db -out:file:silent $fn\.out -out:suffix _$j -user_tag _$j\n";
        		#$run_str[$node_i] .= "$cmds[$k] core_asa=25 surface_asa=45 -database $rosetta_db -out:file:silent $fn\.out -out:suffix _$j -user_tag _$j\n";
			$ind++;
		}
	}
}

for(my $i=0;$i<scalar @run_str;$i++){
	my $fn = "$name\_$i";
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
	"asa!",
	"bf!",
    );
    return %opts;
}

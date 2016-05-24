use strict;
use warnings;
use POSIX qw(floor);

my $app = '/work/binchen/mygit/Rosetta/main/source/bin/dock_pdb_into_density.default.linuxgccrelease';
my %options = (
    'database' => '/work/binchen/mygit/Rosetta/main/database/',
    'min' => 'false', #do not do rigid body minimization
    'min_bb' => 'false', #default, do not do backbone minimization
    'n_to_search' => 20000, #how many translations to search
    'n_filtered' => 2000, #how many solutions to take to refinement
    'n_output' => 1000, #how many solutions to output
    'frag_dens' => 0.90, #Fragment density
    'movestep' => 1, #move step of sampling grid
    'max_rot_per_trans' => 10, #maximum rotation search
);
my $model_dir = 'chains';
my $kw = '3j6h_';
my $map_dir = 'maps';
opendir(M,$model_dir) or die("Can't open directory $model_dir:$!");
my @pdbs = grep(/$kw/,readdir(M));
closedir(M);
if(scalar @pdbs > 0){
    @pdbs = sort {$a cmp $b} @pdbs;
    print "PDBs to be docked:",join(" ",@pdbs),"\n";
}else{
    die("No pdbs found match $kw");
}
opendir(D,$map_dir) or die("Can't open directory $map_dir:$!");
my @maps = grep(/\.(mrc|map)$/,readdir(D));
closedir(D);
die("No maps found\n") unless(scalar @maps > 0);
my %maps = (); #keyword resolution
foreach (@maps){
    if(/_(\d+)A/){
	$maps{$1} = $_; #use resolution information as keyword
	print "Find map $_ with resolution $1A\n";
    }else{
	die("No resolution information can be parsed from $_,please name it as *_\${res}A_*\n");
    }
}
open(O,">cmds.sh") or die("can't open file cmds.sh\n");
my @sorted_reso = sort {$a cmp $b} (keys %maps);
my @sf_arr = ('fullatom','fast','ca','window');
foreach my $reso (@sorted_reso){
  foreach my $sf (@sf_arr){  
    $options{'edensity::mapfile'} = $map_dir."/".$maps{$reso};
    $options{'edensity::mapreso'} = $reso;
    #$options{'delR'} = 2;
    $options{'score_func'} = $sf;
    next unless($sf eq 'window');
    foreach my $pdb (@pdbs){
	my $cmd = $app;
	my $output_f_kw = $reso.'A';
	if($pdb =~ /_([^_]+)\.pdb/){
	   $output_f_kw .= "_$1";
	}elsif($pdb =~ /(\w+)\.pdb/){
	   $output_f_kw .= "_$1";
	}
	$output_f_kw .= "_$sf";
	$options{'in:file:s'} = $model_dir."/".$pdb;
	$options{'in:file:native'} = $model_dir."/".$pdb;
	$options{'out:file:silent'} = $output_f_kw.".out";
	my @options_kw = sort keys %options;
	foreach my $option (@options_kw){
	    $cmd .= " -$option $options{$option}";
        }
	print O $cmd," >log_$output_f_kw","\n";
    }
  }  
}
close O;

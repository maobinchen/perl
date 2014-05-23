#!/usr/bin/env perl
use strict;
use warnings;
use Cwd;

my $dir = $ARGV[0];
my $rms_cutoff = 0.8;
die("Usage: $0 <pdbs_folder> [decoy_file] [rms_cutoff=%f] [fastff]") unless(-d $dir);
my $decoy_f = $ARGV[1] if(-e $ARGV[1]);
my %options = &getCommandLineOptions(); 
$rms_cutoff = $options{rms_cutoff} if($options{rms_cutoff});
my $run_fastff = 0;
$run_fastff = 1 if($options{fastff});
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
my %info = ();
open(B,">boinc_submit");
my @rms_kw = ('min','qt1','median','mean','qt3','max');
my @fast_ff = ();
for (my $i=0;$i<$n_str;$i++){
    my $kw = $1 if($decoys[$i] =~ /(.*)\.pdb/);
    my $frag_dir = $kw.'_fragments';
    if(-e "$frag_dir/good_fragments_count.txt"){
	chdir($frag_dir);
	open(F,"good_fragments_count.txt");
	while(<F>){
	    chomp;
	    my @values = split(/\s+/,$_);
	    $info{$kw}->{count} = $values[1];
	    $info{$kw}->{good} = $values[2];
	    $info{$kw}->{total} = $values[3];
	    $info{$kw}->{total_exp} = $values[4];
	}
	close F;
	my $min_rms_s = `/work/binchen/bin/ana_frag.R | tail -n 1`;
	chomp($min_rms_s);
	$min_rms_s =~ s/^\s+//;
	my @min_frags = split(/\s+/,$min_rms_s);
	for(my $k=0;$k<6;$k++){
	    $info{$kw}->{$rms_kw[$k]}= $min_frags[$k];
	}
	if($info{$kw}->{max} < $rms_cutoff){
	    system("/work/binchen/bin/boinc/prepare_fold.py $kw");
	    system("/work/binchen/bin/boinc/submit_to_boinc.py run.fold.boinc.job");
	    my $bi = `more boinc.dat`;
	    chomp($bi);
	    print B "$path/$frag_dir $kw $bi\n";
	    push(@fast_ff,$frag_dir);
	}
	chdir('..');
    }else{
	print "Fragment not exist for $kw\n";
    }	
}
close B;
my @out_decoys = sort {$info{$a}->{max}<=>$info{$b}->{max}} (keys %info);
open(O,">frag_qual");
my @out_kws = (('id','count','good','total','total_exp'),@rms_kw);
print O join("\t",@out_kws),"\n";
foreach my $kw (@out_decoys){
    my @outs = ($kw);
    foreach (@out_kws){
	next if($_ eq 'id');
	push(@outs,$info{$kw}->{$_});
    }	
    print O join("\t",@outs),"\n";
}
close O;

if($run_fastff && scalar @fast_ff > 0){
    my $ff_script = '/work/dadriano/DEVEL/python/deNovoDesignTools/theFragmentReducer/run_theFFFragmentReducer_local.bash';
    foreach (@fast_ff){
	chdir($_) or die("can't go to directory:$!");
	system("$ff_script");
	do{
	    sleep(60);
	}until(-e 'fast_ffplot.png');
	chdir('..');
    }	
}


sub getCommandLineOptions {
    use Getopt::Long;
    my %opts = ();
    &GetOptions (\%opts,"rms_cutoff=f","fastff!");
    return %opts; 
}

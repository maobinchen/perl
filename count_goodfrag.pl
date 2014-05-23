#!/usr/bin/perl

#use lib "$ENV{'HOME'}/perllib";
use lib "/work/nobuyasu/perllib";

use App::Options(
    values => \%optn,            
    option => {
        s => {
            type => 'string',
	    description => 'quality file',
        },
        l => {
            type => 'string',
	    description => 'list of frag quality files',
        },
        max => {
            type => 'float',
	    default => '1.5',
	    description => 'threshold for good fragments ',
        },
    },
    );

if( !$optn{l} && !$optn{s} ){
    die("Option of file or list is required.");
}

my @fragfiles;
if( $optn{s} ){
    push( @fragfiles, $optn{s} );
}elsif( $optn{l} ){
    open(INP,"$optn{l}")||die("cannot open $optn{l}");    
    while(<INP>){
	chomp;
	split;
	push( @fragfiles, $_[0] );
    }
    close(INP);
}

foreach my $f ( @fragfiles ){

    $count = 0;
    $good = 0;
    $total = 0;
    $tot_exp = 0;
    $tot_exp_weighted = 0;
    open(INP,"$f")||die("cannot open $f");
    @c = ();
    while(<INP>){
	chomp;
	split;
	$count++;

        $p = $_[3];

	$tot_exp += exp( -$p );
	if( $p < $optn{max} ){
	    $c[ $_[1] ] ++;
	    $good++;
	    $total += 1/$c[ $_[1] ];
	}
#        $tot_exp_weighted += exp( -$p )*(1/$c[ $_[1] ] );

    }
    close(INP);
    print "$f $count $good $total $tot_exp \n";

}

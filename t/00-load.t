#!perl -T

use Test::More tests => 4;

BEGIN {
	use_ok( 'Shrike' );
	use_ok( 'Shrike::Session' );
	use_ok( 'Shrike::Mapper' );
	use_ok( 'Shrike::Driver' );
}

diag( "Testing Shrike $Shrike::VERSION, Perl $], $^X" );

package Shrike::Map;
use Moose;

has driver   => ( is => 'ro', isa => 'Shrike::Driver'   );
has inflator => ( is => 'ro', isa => 'Shrike::Inflator' );
has delfator => ( is => 'ro', isa => 'Shrike::Deflator' );

no Moose;
1;

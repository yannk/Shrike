package Shrike::PK;
use strict;
use warnings;

=head1 NAME

Shrike::PK - Base class for the object managing model's primary keys

=head1 DESCRIPTION

A Shrike::PK is a member of a L<Shrike::Map> object and is used by the map
to manipulate primary keys of the objects, most notabily by helping generating
a primary key or some of its component when necessary at insert time.

=head1 USAGE

=cut

use Object::Tiny qw{ generate_cb }; 

sub generate {
    my $pk = shift;
    my ($model) = @_; 
    return $pk->generate_cb->($model);
}

1;

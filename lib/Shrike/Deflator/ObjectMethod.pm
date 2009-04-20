package Shrike::Deflator::ObjectMethod;
use warnings;
use strict;

use base 'Shrike::Deflator';

=head1 NAME

Shrike::Deflator::InObject

=head1 DESCRIPTION

A class of deflator that delegates the responsability to the object itself.
So the object must implement a C<deflate> method.

=cut

sub deflate {
    my $class = shift;
    my $model = shift;
    return $model->deflate(@_);
}

1;

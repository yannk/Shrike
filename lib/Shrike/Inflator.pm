package Shrike::Inflator;

use warnings;
use strict;

=head1 NAME

Shrike::Inflator - Base class for turning flat hash to objects
for storage

=head1 METHODS

=head2 inflate(\%hash, $class)

Takes data from the store, and return data ready to be passed to the setter of
object's attribute

=cut

sub inflate {
    my $class = shift;
    my ($data, $model_class) = @_;
    return $model_class->new(%$data);
}

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

"Nobody reads that, really";

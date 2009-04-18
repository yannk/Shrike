package Shrike::Transformer;

use warnings;
use strict;

=head1 NAME

Shrike::Transformer - Base class for inflator/deflator

=head1 METHODS

=head2 deflate

Takes an object in argument and return a hashref of data to pass to the driver
for storage.

=cut

sub deflate {

}

=head2 inflate

Takes data from the store, and return data ready to be passed to the setter of
object's attribute

=cut

## consider the following problem where we have an object wih n attributes
## and a deflator for one column consisting in zipping the data and crypt it
## (or whatever is expensive), We don't want to deflate this object each time
## we do an update if it hasn't changed, so we need a way to selectively 
## deflate some attributes only.
sub inflate {

}

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

"Nobody reads that, really";

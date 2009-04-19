package Shrike::Deflator;

use warnings;
use strict;

=head1 NAME

Shrike::Deflator - Base class for turning objects to flat hash suitable
for storage

=head1 METHODS

=head2 deflate($model [, \@attributes ])

Takes an object in argument and return a hashref of data to pass to the driver
for storage.

Optionaly, the caller can restrict the keys of the hash returned to a subset
of what it would be without being explicit. This is useful for UPDATE case
(in DBI case for example), when the caller is only interested to update only
what it knows has change.

=cut

sub deflate {

}

"Nobody reads that, really";

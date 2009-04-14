package Shrike;

use warnings;
use strict;

=head1 NAME

Shrike - A fast persistent framework for Moose objects

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Shrike allows you to persist your objects with great flexibility, and loosely
couple your objects with their datastore(s).

    package User;
    has first_name => (is => 'rw', isa => 'Str');
    has last_name  => (is => 'rw', isa => 'Str');
    has age        => (is => 'rw', isa => 'Int');

    package main;
    $driver  = get_driver();
    $session = Shrike::Session->new;
    $mapper  = Shrike::Mapper->new;
    $mapper->map(User => $driver);

    $session->add($user);

    ## write objects to the datastore
    $session->sync;

=head1 DESCRIPTION
...

=cut


=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-shrike at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Shrike>.  I will be notified,
and then you'll automatically be notified of progress on your bug as I make
changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Shrike


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Shrike>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Shrike>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Shrike>

=item * Search CPAN

L<http://search.cpan.org/dist/Shrike/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

"http://en.wikipedia.org/wiki/The_Shrike";

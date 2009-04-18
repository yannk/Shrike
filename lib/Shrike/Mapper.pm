package Shrike::Mapper;
use Moose;

has driver      => ( is => 'ro', isa => 'Shrike::Driver'     );
has transformer => ( is => 'ro', isa => 'Shrike::Transformer');

=head1 NAME

Shrike::Mapper - Maps classes to drivers.

=head1 SYNOPSIS

Mapper defines how classes are mapped to drivers.

    use Shrike::Mapper;

    $mapper = Shrike::Mapper->new;
    $mapper->map( $class => $driver );

=head1 DESCRIPTION

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

"The Hegemony Consul sat on the balcony of his ebony spaceship...";

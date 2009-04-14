package Shrike::Session;
use Moose;

=head1 NAME

Shrike::Session - Responsible for maintaining the state of the dialog between
objects and stores.

=head1 SYNOPSIS

    use Shrike::Session;

    $session = Shrike::Session->new();
    $session->add(@objects);
    $session->delete($object);

    $session->abort;
    # - or -
    $session->sync

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

no Moose;
"Put something smart here"

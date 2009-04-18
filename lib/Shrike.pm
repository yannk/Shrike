package Shrike;
use Moose;
use MooseX::Singleton;

=head1 NAME

Shrike - A fast persistent framework for Moose objects

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

has maps => (is => 'rw', isa => 'HashRef[Item]');


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

    $user = User->new(first_name => "Yann", last_name => "Kerherve");
    $session->add($user);

    ## insert object in the store
    $session->sync;
    printf "User is identified by '%s'\n", $user->pk_str;

    ## update object in the store
    $user->age(31);
    $session->sync;
    $pk = $user->pk;

    $user = $session->lookup($pk);
    is $user->first_name, "Yann";

=head1 DESCRIPTION

=cut

=head1 FAQ

=head2 What is Shrike?

Shrike is a experiment to persist Moose objects in various Store, with web 
applications in mind.

=head2 Is it an ORM?

No, though you could build one on top of it (and maybe we would). Shrike
is first and foremost a persistence framework, but it doesn't assume a
Relational model, or doesn't impose you to build SQL programatically.
It supports non-relational datastores.

=head2 But there is plenty of ORM already...

Shrike is not an ORM.

=head2 But ORM are good, aren't they?

Seriously? ORM suck. They are good at 80% of the thing, and the 20
remaining are very difficult if not impossible to get right.

=head2 So, why should I use Shrike instead of ORM X?

Maybe you should use ORM X, (especially since as I write this POD, there is
not a single line of code written in Shrike yet).
But If you feel trapped in your ORM, or if you are building large, distributed
applications and you know that you want sharding, caching, denormalization,
then maybe you should give Shrike a try and contribute.

=head2 I think this is just crap, because X, Y and Z

That's good bring it on, share your thoughts, as I'm not convinced myself
yet that this is not crap, and that I shouldn't be watching 'Lost', instead.


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

no Moose;
"http://en.wikipedia.org/wiki/The_Shrike";

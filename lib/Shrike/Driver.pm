package Shrike::Driver;

use warnings;
use strict;

=head1 NAME

Shrike::Driver - Base class for all drivers in Shrike

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

sub get       { __abstract('get')       }
sub get_multi { __abstract('get_multi') }
sub insert    { __abstract('insert')    }
sub replace   { __abstract('replace')   }
sub update    { __abstract('update')    }
sub delete    { __abstract('delete')    }

sub __abstract { die "You need to override " . shift() }

"Nobody reads that, really";

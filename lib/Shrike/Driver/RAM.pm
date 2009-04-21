package Shrike::Driver::RAM;
use strict;
use warnings;

use Object::Tiny qw{cache};
use base qw/Shrike::Driver/;
use Shrike::Util;
use Carp;

## tired thoughts:
# * all cache should have the same base behaviour (stringify, *flate, do)
# * maybe make 2cachekey a codref?
# * on update(), 2 modes -> update cache preemptively, or delete cache
#   (assuming that this will run in a Stack most of the time)

sub get {
    my $driver = shift;
    my ($session, $model_class, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return $driver->cache->{$cachekey};
}

sub get_multi {
    my $driver = shift;
    my ($session, $model_class, $pks) = @_;
    croak "no PK list passed in argument to get_multi $pks"
        unless $pks && ref $pks eq 'ARRAY';

    my @cachekeys = map {
        $_ ? Shrike::Util::pk2cachekey($model_class, $_)
           : undef
    } @$pks;
    my $cache = $driver->cache;

    ## can't use a hash slice because of dupes 
    #return [ @$cache{@cachekeys} ];
    my @results;
    for (@cachekeys) {
        push @results, defined $_ ? $cache->{$_} : undef;
    }
    return \@results;
}

## XXX should I make this behave like DBI (dies if cache already exists?)
sub insert {
    my $driver = shift;
    my ($session, $model_class, $data, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    $driver->cache->{$cachekey} = { %$data };
    return 1;
}

sub replace { shift->insert(@_) }

## XXX revisit
## wrong: not the same arguments
sub update { shift->insert(@_) }

sub delete {
    my $driver = shift;
    my ($session, $model_class, $pk) = shift;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return ! !delete $driver->cache->{$cachekey};
}

1;

package Shrike::Driver::RAM;
use strict;
use warnings;

use Object::Tiny qw{cache inflate deflate};
use base qw/Shrike::Driver/;
use Shrike::Util;

## tired thoughts:
# * all cache should have the same base behaviour (stringify, *flate, do)
# * maybe make 2cachekey a codref?
# * on update(), 2 modes -> update cache preemptively, or delete cache
#   (assuming that this will run in a Stack most of the time)

sub get {
    my $driver = shift;
    my ($session, $model_class, $pk);
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return $driver->cache->{$cachekey};
}

sub get_multi {
    my $driver = shift;
    my ($session, $model_class, $pks) = @_;

    my @cachekeys = map { Shrike::Util::pk2cachekey($model_class, $_) } @$pks;
    my $cache = $driver->cache;
    return [ @$cache{@cachekeys} ];
}

## XXX should I make this behave like DBI (dies if cache already exists?)
sub insert {
    my $driver = shift;
    my ($session, $model) = shift;
    my $data = $driver->deflate->($model);
    my $model_class = ref $model;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $model->pk);
    $driver->cache->{$cachekey} = $data;
    return 1;
}

sub replace { shift->insert(@_) }

## XXX revisit
sub update { shift->insert(@_) }

sub delete {
    my $driver = shift;
    my ($session, $model) = shift;
    my $model_class = ref $model;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $model->pk);
    delete $driver->cache->{$cachekey};
    return 1;
}

1;

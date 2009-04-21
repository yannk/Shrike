package Shrike::Driver::Memcached;
use strict;
use warnings;

use Object::Tiny qw{cache};
use base qw/Shrike::Driver/;
use Shrike::Util;
use Carp;

sub get {
    my $driver = shift;
    my ($session, $model_class, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return $driver->cache->get($cachekey);
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
    my $hash_result = $driver->cache->get_multi(@cachekeys);

    my @results;
    for (@cachekeys) {
        push @results, defined $_ ? $hash_result->{$_} : undef;
    }
    return \@results;
}

sub insert {
    my $driver = shift;
    my ($session, $model_class, $data, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    $driver->cache->set($cachekey => { %$data });
    return 1;
}

sub replace { shift->insert(@_) }

## XXX revisit
sub update { shift->insert(@_) }

sub delete {
    my $driver = shift;
    my ($session, $model_class, $pk) = shift;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return ! ! $driver->cache->delete($cachekey);
}

1;

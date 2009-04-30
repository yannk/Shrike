package Shrike::Driver::TokyoTyrant;
use strict;
use warnings;

use Object::Tiny qw{rdb};
use base qw/Shrike::Driver/;
use Shrike::Util;
use Carp;

sub get {
    my $driver = shift;
    my ($session, $model_class, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return $driver->rdb->get($cachekey);
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

    my %records = map {
        Shrike::Util::pk2cachekey($model_class, $_) => undef
    } grep { defined } @$pks;

    my $rdb = $driver->rdb;
    if ($rdb->mget(\%records)) {
        my $ecode = $rdb->ecode;
        croak sprintf "error getting results from mget [%d] %s",
            $ecode, $rdb->errmsg($ecode);
    }

    my @results;
    for (@cachekeys) {
        push @results, defined $_ ? $records{$_} : undef;
    }
    return \@results;
}

sub insert {
    my $driver = shift;
    my ($session, $model_class, $data, $pk) = @_;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    warn "Put $cachekey";
    $driver->rdb->put($cachekey => { %$data });
    return 1;
}

sub replace { shift->insert(@_) }

## XXX revisit
sub update { shift->insert(@_) }

sub delete {
    my $driver = shift;
    my ($session, $model_class, $pk) = shift;
    my $cachekey = Shrike::Util::pk2cachekey($model_class, $pk);
    return ! ! $driver->rdb->out($cachekey);
}

1;

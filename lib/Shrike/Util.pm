package Shrike::Util;
use strict;
use warnings;
use Carp;

sub pk2cachekey {
    my ($model_class, $pk) = @_;
    croak "pk is required" unless defined $pk;
    my $ref = ref $pk;
    if ($ref) {
        if ($ref eq 'ARRAY') {
            return join ":", $model_class, @$pk;
        }
    }
    croak "Can't make a cache key out of '$model_class' and '$pk'";
}

sub pk2binkey {
    my ($pk) = shift;
    ## might want to use Quads here
    my $key = pack "N*", @$pk;
    return $key;
}

sub fast_pk2cachekey {
    return join ":", shift, @{ shift() };
}

1;

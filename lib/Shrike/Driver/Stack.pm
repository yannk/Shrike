package Shrike::Driver::Stack;
use strict;
use warnings;

use Object::Tiny qw{sub_drivers};
use base qw/Shrike::Driver/;

sub get {
    my $driver = shift;

    for (@{ $driver->sub_drivers }) {
        my $object = $_->get(@_);
        return $object if $object;
    }
    return;
}

## for each driver in order, we get what the previous driver
## left us to do
sub get_multi {
    my $driver = shift;
    my ($model_class, $pks) = @_;

    my @results = (undef) x scalar @$pks; # init results
    my @i_map   = \(@$pks);
    my @o_map   = \(@results);

    my @prev_map = ();
    my @map = ();
    for my $d (@{ $driver->sub_drivers }) {
        my $got = $d->get_multi($model_class, [ map $$_, @i_map ]);
        my @new_i_map;
        my @new_o_map;
        for (my $i = 0; $i < scalar @$got; $i++) {
            my $obj = $got->[$i];
            if (defined $obj) {
                ${ $o_map[$i] } = $obj;
            }
            else {
                push @new_i_map, $i_map[$i];
                push @new_o_map, $o_map[$i];
            }
        }
        last unless scalar @new_o_map;
        @i_map = @new_i_map;
        @o_map = @new_o_map;
    }
    return \@results;
}

sub insert {
    my $driver = shift;
    my $res = 1;
    for my $d (@{ $driver->sub_drivers }) {
        $res &&= ! ! $d->insert(@_);
    }
    return $res;
}

sub replace {
    my $driver = shift;
    my $res = 1;
    for my $d (@{ $driver->sub_drivers }) {
        $res &&= ! ! $d->replace(@_);
    }
    return $res;
}

sub update {
    my $driver = shift;
    my $res = 1;
    for my $d (@{ $driver->sub_drivers }) {
        $res &&= ! ! $d->update(@_);
    }
    return $res;
}

sub delete {
    my $driver = shift;
    my $res = 1;
    for my $d (@{ $driver->sub_drivers }) {
        $res &&= ! ! $d->delete(@_);
    }
    return $res;
}

1;

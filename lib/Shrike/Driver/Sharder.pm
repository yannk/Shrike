package Shrike::Driver::Sharder;
use strict;
use warnings;

use Object::Tiny qw{shards get_func new_func model_func};
use base qw/Shrike::Driver/;

sub get {
    my $driver = shift;

    my $func = $driver->get_func;
    my $i = eval { $func->($driver, @_) };
    return if $@;
    my $shard_driver = $driver->shards->[$i];
    return $shard_driver->get(@_);
}

## we identify what ids belong to what shard and we mix all 
## that back in order
sub get_multi {
    my $driver = shift;
    my ($session, $model_class, $pks) = @_;

    my @results = (undef) x scalar @$pks; # init results

    my $subs = $driver->shards;
    my $func = $driver->get_func;
    my %distribution;
    for (my $i = 0; $i < scalar @$pks; $i++) {
        my $pk = $pks->[$i];
        next unless $pk;
        ## that's a lot of function calls... room for later optimization
        my $shard = eval { $func->($driver, $session, $model_class, $pk) };
        next if $@;
        push @{ $distribution{input}{$shard} }, $pk;
        push @{ $distribution{output}{$shard} }, \$results[$i];
    }

    ## note that an efficient way of doing this would be to 
    ## all shard in parallel, but here is just a proof of concept
    for my $shard (keys %{ $distribution{input} } ) {
        my $input = $distribution{input}{$shard};
        my $got = $subs->[$shard]->get_multi($session, $model_class, $input);
        for (my $i = 0; $i < scalar @$got; $i++) {
    #        use Data::Dumper; warn Dumper \%distribution;
            ${ $distribution{output}{$shard}[$i] } = $got->[$i];
        }
    }
    return \@results;
}

sub insert {
    my $driver = shift;
    my $func = $driver->new_func;
  #  warn $func->($driver, @_);
    my $d = $driver->shards->[ $func->($driver, @_) ];
    return $d->insert(@_);
}

sub replace { die "soon" }

sub update {
    my $driver = shift;
    my $func = $driver->model_func;
    my $d = $driver->shards->[ $func->($driver, @_) ];
    return $d->update(@_);
}

sub delete {
    my $driver = shift;
    my $func = $driver->model_func;
    my $d = $driver->shards->[ $func->($driver, @_) ];
    return $d->delete(@_);
}

1;

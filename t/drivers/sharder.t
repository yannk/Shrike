use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib', ];

use_ok 'Shrike::Driver::Sharder';
use Carp;
use Shrike::Driver::RAM;
use Shrike::Session;
use Shrike::Mapper;

my $class = "class";

my $m = Shrike::Mapper->new;
my $s = Shrike::Session->new( mapper => $m );

## 3 RAM sharded
my %h = ( 1 => {}, 2 => {}, 3 => {} );
my @d;
for (1..3) {
    push @d, Shrike::Driver::RAM->new( cache => $h{$_} );
}

## Sharder::Random->new( shards => 3 );
my $sharder = Shrike::Driver::Sharder->new(
    shards => [ $d[0], $d[1], $d[2] ],
    get_func => sub {
        my $driver = shift;
        my ($session, $model_class, $pk) = @_;
        my $user_id = $pk->[0];
        my $subs = $driver->shards;
        ## this is pretty stupid, but this is a driver test, remember
        #my $usermap = $session->lookup(UserMap => [$user_id]);
        #my $i = $usermap->shard;
        my $i = $user_id % scalar @$subs;
        return $i ? $i - 1 : scalar @$subs - 1;
    },
    new_func => sub {
        my $driver = shift;
        my ($session, $model_class, $data, $pk) = @_;
        my $subs = $driver->shards;
        # in the normal case random would be better.
        # here we need predictability
        #return int rand scalar @$subs;
        my $user_id = $pk->[0];
        my $i = $user_id % scalar @$subs;
        return $i ? $i - 1 : scalar @$subs - 1;
    },
    model_func => sub {
        my $driver = shift;
        my ($session, $model) = @_;
        my $subs = $driver->shards;

        ## normal access case
        my $user_id = $model->user_id;
        ## this is pretty stupid, but this is a driver test, remember
        my $i = $user_id % scalar @$subs;
        return $i ? $i - 1 : scalar @$subs - 1;
    },
);

isa_ok $sharder, 'Shrike::Driver::Sharder';
is $sharder->get($s, $class, [1]), undef, "absent";

ok $sharder->insert($s, $class, {"un", ''}, [1]), "inserted";
is_deeply $h{1}{"class:1"}, {"un", ''}, "driver 1 got it";
is_deeply $h{2}{"class:1"}, undef, "but not driver 2";
is_deeply $h{3}{"class:1"}, undef, "neither driver 3";

## now getting it back
is_deeply $sharder->get($s, $class, [1]), {"un", ''}, "got it back";

## trying get_multi
{
    for (2..4) {
        ok $sharder->insert($s, $class, {$_, ''}, [ $_ ]), "inserted";
    }
    is_deeply $sharder->get_multi($s, $class, [[1], [1], [2], [3], [4], undef]),
          [ {"un", ''}, {"un", ''}, {"2", ''}, {"3", ''}, {"4", ""}, undef ],
          "got it back";
}

## TODO: updates, deletes,...

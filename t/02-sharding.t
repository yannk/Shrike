use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib', './sharding'];
use Carp;

use_ok 'Shrike::Driver::Sharder';
use Shrike::Driver::RAM;
use Shrike::Mapper;
use Shrike::Session;
use Shrike::Inflator;
use Shrike::Deflator::ObjectMethod;

## 3 RAM stacks
my %h = ( 1 => {}, 2 => {}, 3 => {} );
my @d;
for (1..3) {
    push @d, Shrike::Driver::RAM->new( cache => $h{$_} );
}

use_ok 'User';
use_ok 'UserMap';

## Driver::Sharder::Random->new( shards => 3 );
my $sharder = Shrike::Driver::Sharder->new(
    shards => \@d, 
    get_func => sub {
        my $driver = shift;
        my ($session, $model_class, $pk) = @_;
        my $user_id = $pk->[0];
        my $usermap = $session->get(UserMap => [$user_id]);
        confess "no map for $user_id" unless $usermap;
        return $usermap->shard;
    },
    new_func => sub {
        my $driver = shift;
        my ($session, $model_class, $data, $pk) = @_;
        my $subs = $driver->shards;
        my $shard = int rand scalar @$subs + 1;
        use Carp; Carp::confess('x');
        my $map = UserMap->new(user_id => $pk->[0], shard => $shard);
        $session->add($map);
        return $shard;
    },
    model_func => sub {
        my $driver = shift;
        my ($session, $model) = @_;
        my $subs = $driver->shards;

        my $user_id = $model->user_id;
        my $usermap = $session->get(UserMap => [$user_id]);
        confess "no map for $user_id" unless $usermap;
        return $usermap->shard;
    },
);

isa_ok $sharder, 'Shrike::Driver::Sharder';
my $mapper  = Shrike::Mapper->new();
my $session = Shrike::Session->new( mapper => $mapper );

my $inflator = Shrike::Inflator->new;
my $deflator = Shrike::Deflator::ObjectMethod->new;
$mapper->map(User    => $sharder, $inflator, $deflator);
$mapper->map(UserMap => $d[0],    $inflator, $deflator);

is $session->get('User', [1]), undef, "absent object";

my $u = User->new(
    first_name => 'Hugo',
    last_name  => 'Reyes',
    user_id    => 1, 
);
$DB::single = 1;
$session->add($u);

$session->sync;

my $u2 = $session->lookup(User => [1]);
use YAML; warn Dump $u2;

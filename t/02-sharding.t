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
use Shrike::PK;

## 3 RAM shards
my %h = ( 1 => {}, 2 => {}, 3 => {} );
my @d;
for (1..3) {
    push @d, Shrike::Driver::RAM->new( cache => $h{$_} );
}

use_ok 'User';
use_ok 'UserMap', "UserMap is an object just to make things complicated";

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
        my $shard = int (rand scalar @$subs) + 1;
        my $map = UserMap->new(user_id => $pk->[0], shard => $shard);
        $session->add($map);
        return $shard;
    },
    model_func => sub {
        my $driver = shift;
        my ($session, $model_class, $data, $pk) = @_;
        my $subs = $driver->shards;

        my $user_id = $data->{user_id};
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
my $i = 0;
my $pk_generator = Shrike::PK->new( generate_cb => sub {
    my $model = shift;
    return [ $model->user_id || $i++ ];
});
$mapper->map(User    => $sharder, $pk_generator, $inflator, $deflator);
$mapper->map(UserMap => $d[0],    $pk_generator, $inflator, $deflator);

is $session->get('User', [1]), undef, "absent object";

my $u = User->new(
    first_name => 'Hugo',
    last_name  => 'Reyes',
    user_id    => 1, 
);
$DB::single = 1;
$session->add($u);

$session->sync;

my $u2 = $session->get(User => [1]);
ok $u2, "Got our sharded object back";
isa_ok $u2, 'User';
is_deeply $u2->pk, [1], "the same PK we asked for";
is $u2->first_name, "Hugo";

$u2->first_name("Hurley");
$session->sync;
$u2 = $session->get(User => [1]);
is $u2->first_name, "Hurley", "Got updated first name";
my $map = $session->get(UserMap => [1]);
like $map->shard, qr/[123]/, "shard is " . $map->shard;

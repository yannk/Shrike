use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib',];

use_ok 'Shrike::Driver::RAM';
use Shrike::Session;
use Shrike::Mapper;

my $class;
my $h;
my $m       = Shrike::Mapper->new;
my $s       = Shrike::Session->new(mapper => $m);
my $driver  = Shrike::Driver::RAM->new(
    cache   => {}, # hmm. I also need to make it work with Cache::Cache
                   # I want LRU etc...
);

isa_ok $driver, 'Shrike::Driver::RAM';
$class = "someclass";
$h = $driver->get($s, $class, [2]);
is_deeply $h, undef, "nothing exist in the cache";

$h = { somekind => "of", object => 1 };
ok $driver->insert($s, $class, $h, [1]), "successful insert";
is_deeply $driver->get($s, $class, [1]), $h, 'Got h back';

## change the original object
$h->{somekind} = "tata";
isnt $driver->get($s, $class, [1])->{somekind}, $h->{somekind},
     'but cache has a _copy_ of it';

## test multi
my @pks = (
    [7],
    [1,2],
    [3,4],
    [5],
    [5],
    undef,
    'some invalid key',
);

my $res = dies_ok {
    $driver->get_multi($s, $class, \@pks)
} "invalid input dies (one of the key is not a hashref)";
pop @pks;
$res = $driver->get_multi($s, $class, \@pks);
isa_ok $res, 'ARRAY', "got result back";
is @$res, scalar @pks, "same size array";
is_deeply $res, [ (undef) x scalar @pks ], "no match in this driver for now";

## now insert a few stuff in the cache and query the driver again
$driver->insert($s, $class, { 7 => 1     }, [    7 ]);
$driver->insert($s, $class, { cmplx => 1 }, [ 3, 4 ]);
$driver->insert($s, $class, { 5 => 1     }, [    5 ]);
$res = $driver->get_multi($s, $class, \@pks);

is_deeply($res ,[
    { 7 => 1 },
    undef,
    { cmplx => 1 },
    { 5 => 1 },
    { 5 => 1 },
    undef,
], "dupe result ok, undef is undef, got our data back");

ok $driver->update($s, $class, { 5 => 2 }, [ 5 ]), "updating...";
is $driver->get($s, $class, [5])->{5}, 2, "... update works";
ok $driver->replace($s, $class, { 5 => 3 }, [ 5 ]), "replacing existing...";
is $driver->get($s, $class, [5])->{5}, 3, "... replace works";
ok $driver->replace($s, $class, { x => 1 }, [ 6 ]), "replacing new slot";
is $driver->get($s, $class, [6])->{x}, 1, "... replace works";

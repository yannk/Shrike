use strict;
use warnings;

use Test::More 'no_plan';
use Find::Lib libs => ['../lib', '../simple' ];
use testcommon;
use User;

use_ok 'Shrike::Driver::RAM';

my $class;
my $h;
my $driver  = Shrike::Driver::RAM->new(
    cache   => {}, # hmm. I also need to make it work with Cache::Cache
                   # I want LRU etc...
);

isa_ok $driver, 'Shrike::Driver::RAM';
$class = "something";
$h = $driver->get($class, [2]);
is_deeply $h, undef, "nothing exist in the cache";

$h = { somekind => "of", object => 1 };
ok $driver->insert($class, $h, [1]), "successful insert";
is_deeply $driver->get($class, [1]), $h, 'Got h back';

## change the original object
$h->{somekind} = "tata";
isnt $driver->get($class, [1])->{somekind}, $h->{somekind},
     'but cache has a _copy_ of it';


use strict;
use warnings;

use Test::More 'no_plan';
use Find::Lib libs => ['../lib', '../simple' ];
use testcommon;
use User;

use Shrike::Session;
use Shrike::Mapper;
use Shrike::Util;

use_ok 'Shrike::Driver::RAM';

my $mapper  = Shrike::Mapper->new;
my $session = Shrike::Session->new;

my $inflate = Shrike::Util::std_inflate;
my $deflate = Shrike::Util::std_deflate;

my $driver  = Shrike::Driver::RAM->new(
    inflate => $inflate,
    deflate => $deflate,
    cache   => {}, # hmm. I also need to make it work with Cache::Cache
                   # I want LRU etc...
);

$mapper->map(User => $driver);

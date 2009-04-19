use strict;
use warnings;

use Test::More;

BEGIN {
    unless (eval { require DBD::SQLite }) {
        plan skip_all => 'Tests require DBD::SQLite';
    }
    unless (eval { require DBI }) {
        plan skip_all => 'Tests require DBI';
    }
}

plan 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib', '../simple'];

## SQLite requirement
use testcommon;
use_ok 'Shrike::Driver::DBI';

my $class;
my $h;
my $dsn = testcommon::init_db('user');

my $driver  = Shrike::Driver::DBI->new(
    table   => 'user',
    columns => [qw/ user_id first_name last_name /],
    pk      => ['user_id'],
    ## not quite sure about the way to get dbh, just yet
    dsn     => $dsn,
);

## there is no data in the table, so anything will return undef
is_deeply $driver->get("not relevant", [1]), undef, "got undef for inexistent";

## add some data and retrieve it
{
    $h = {
        first_name => 'Yann',
        last_name  => 'Kerherve',
        user_id    => 1,
    };
    ok $driver->insert("not relevant", $h, [1]), "inserted";
    is_deeply $driver->get("not relevant", [1]), $h, "got object back";
}

use strict;
use warnings;

use Test::More;
#XXX test requires a few things to run, or skip_all XXX
use Find::Lib libs => ['./lib', './simple'];
use testcommon;

use Test::Exception;
use DBI;
use Cache::Memcached;
use Shrike::Mapper;
use Shrike::Session;
use Shrike::Inflator;
use Shrike::Deflator::ObjectMethod;
use Shrike::PK;
use Shrike::Driver::DBI;
use Shrike::Driver::RAM;
use Shrike::Driver::Memcached;
use Shrike::Driver::Stack;
use Shrike::Driver::TokyoTyrant;
use User;

plan 'no_plan';

my $dsn = testcommon::init_db('user');

my $ram = Shrike::Driver::RAM->new( cache => {} );
my $mc  = Shrike::Driver::Memcached->new(
    cache => Cache::Memcached->new(
        namespace => 'bla',
        servers   => [ '127.0.0.1:11211' ],
    ),
);
my $dbi = Shrike::Driver::DBI->new(
    table       => 'user',
    columns     => [ qw/ user_id first_name last_name / ],
    primary_key => ['user_id'],
    dsn         => $dsn,
); 

use TokyoTyrant;
my $rdb = TokyoTyrant::RDBTBL->new();
# connect to the server
if(!$rdb->open("localhost", 1978)){
    my $ecode = $rdb->ecode();
    printf STDERR ("open error: %s\n", $rdb->errmsg($ecode));
}
my $ttr = Shrike::Driver::TokyoTyrant->new( rdb => $rdb ); 

my $stack = Shrike::Driver::Stack->new(
    sub_drivers => [ $ram, $mc, $ttr ],
);

my $u = User->new(
    user_id    => 1,
    first_name => 'Yann',
    last_name  => 'Kerherve',
);

my $inflator = Shrike::Inflator->new;
my $deflator = Shrike::Deflator::ObjectMethod->new;
my $i = 0;
my $pk_generator = Shrike::PK->new( generate_cb => sub {
    my $model = shift;
    return [ $model->user_id || $i++ ];
});

my $m = Shrike::Mapper->new;
my $s = Shrike::Session->new( mapper => $m );

dies_ok { $u->pk      } "no pk()     installed yet";
dies_ok { $u->pk_str  } "no pk_str() installed yet";
dies_ok { $s->add($u) } "User is not mapped yet";

ok $m->map(User => $stack, $pk_generator, $inflator, $deflator), "User is now mapped";
lives_ok { $s->add($u) } "User added to the session";

ok $s->sync, "writing users to the database";

my @user_ids = ([1], [2], [3], [4]);
my $users = $s->get_multi(User => \@user_ids);
is scalar @$users, 1;
is $users->[0]->first_name, 'Yann', "first name is Yann";

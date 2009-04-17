use strict;
use warnings;
use DBI;
use Shrike::Driver::DBI;
use Shrike::Mapper;
use Shrike::Session;

my $dbh = DBI->connect(
    'dbi:mysql:moose',
     'root',
     undef,
) or die DBI->errstr;

my $driver = Shrike::Driver::DBI->new(
    table   => 'user',
    columns => [ qw/
        user_id first_name last_name 
    / ],
    pk      => ['user_id'],
    get_dbh => sub { $dbh },
); 

my $u = User->new(
    first_name => 'Yann',
    last_name  => 'Kerherve',
);

my $mapper  = Shrike::Mapper;

$mapper->map(User => $driver);

my $session = Shrike::Session->new;
$session->add($u);

$session->sync;

my @user_ids;
my $sth = $dbh->prepare('SELECT user_id FROM user');
while (my $row = $sth->fetch) {
    push @user_ids, $row->[0];
}

my $users = $driver->get_multi(\@user_ids)



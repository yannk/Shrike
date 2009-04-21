use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib', ];

use_ok 'Shrike::Driver::Sharder';
use Shrike::Driver::RAM;

my $class = "class";

## 3 RAM stacks
my %h = ( 1 => {}, 2 => {}, 3 => {} );
my @d;
for (1..3) {
    push @d, Shrike::Driver::RAM->new( cache => $h{$_} );
}

## Sharder::Random->new( shards => 3 );
my $stack = Shrike::Driver::Sharder->new(
    sub_drivers => {
        one   => $d[0],
        two   => $d[1],
        three => $d[2],
    },
    shard_func => sub {
        my $driver = shift;
        my ($session, $hash) = @_;
        my $sub    = $driver->sub_drivers;
        if (! $hash) {
            ## insert case
            my $i = int rand scalar @$sub;
            return $sub->[$i];
        }
        ## normal access case
        my $user_id = $hash->{user_id};
        my $usermap = $session->lookup(UserMap => [$user_id]);
        my $i = $usermap->shard;
        my $sub_driver = $sub->[$i]
            or croak "I don't know about this shard $i";
        return $sub_driver;
    },
);

isa_ok $stack, 'Shrike::Driver::Stack';
is $stack->get($class, [1]), undef, "absent from all stacks";

ok $stack->insert($class, {"un", ''}, [1]), "inserted";
for (1..3) {
    is_deeply $h{$_}{"class:1"}, {"un", ''}, "driver $_ got it";
}

## test cascading
{
    $h{1}{"class:2"} = {"2-1", ''};
    $h{2}{"class:2"} = {"2-2", ''};
    $h{3}{"class:2"} = {"2-3", ''};

    $h{2}{"class:3"} = {"3-2", ''};
    $h{3}{"class:3"} = {"3-3", ''};

    $h{3}{"class:4"} = {"4-3", ''};

    my @keys = ( [2], [3], [4], [4], undef, [10],);
    my $res = $stack->get_multi($class, [ @keys ]);

    isa_ok $res, 'ARRAY';
    is scalar @$res, scalar @keys, "Same array size than input";
    my $test = [ map { $_ ? keys %$_ : undef } @$res ];
    is_deeply $test, [ "2-1", "3-2", "4-3", "4-3", undef, undef], "multi worked";
}

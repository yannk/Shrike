use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;
use Find::Lib libs => ['../lib',];

use_ok 'Shrike::Driver::Stack';
use Shrike::Driver::RAM;
use Shrike::Mapper;
use Shrike::Session;

my $class = "class";

my $m  = Shrike::Mapper->new;
my $s  = Shrike::Session->new(mapper => $m);

## 3 RAM stacks
my %h = ( 1 => {}, 2 => {}, 3 => {} );
my @d;
for (1..3) {
    push @d, Shrike::Driver::RAM->new( cache => $h{$_} );
}
my $stack = Shrike::Driver::Stack->new(
    sub_drivers => \@d,
);

isa_ok $stack, 'Shrike::Driver::Stack';
is $stack->get($s, $class, [1]), undef, "absent from all stacks";

ok $stack->insert($s, $class, {"un", ''}, [1]), "inserted";
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
    my $res = $stack->get_multi($s, $class, [ @keys ]);

    isa_ok $res, 'ARRAY';
    is scalar @$res, scalar @keys, "Same array size than input";
    my $test = [ map { $_ ? keys %$_ : undef } @$res ];
    is_deeply $test, [ "2-1", "3-2", "4-3", "4-3", undef, undef], "multi worked";
}

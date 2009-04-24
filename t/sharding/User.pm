package User;
use Moose;

has user_id => (
    is => 'rw', 
    isa => 'Num',
);

has first_name => (
    is       => 'rw',
    isa      => 'Str',
);

has last_name => (
    is       => 'rw',
    isa      => 'Str',
);

has email => (
    is       => 'rw',
    isa      => 'Str',
);

sub deflate {
    my $user = shift;
    return {
        user_id => $user->user_id, 
        first_name => $user->first_name,
        last_name  => $user->last_name,
    };
}

no Moose;
1;

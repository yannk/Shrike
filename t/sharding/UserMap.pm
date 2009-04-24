package UserMap;
use Moose;

has user_id => (
    is => 'rw', 
    isa => 'Num',
);

has shard => (
    is => 'rw',
    isa => 'Num',
);

sub deflate {
    my $user_map = shift;
    return {
        user_id => $user_map->user_id, 
        shard   => $user_map->shard,
    };
}

no Moose;
1;

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

no Moose;
1;

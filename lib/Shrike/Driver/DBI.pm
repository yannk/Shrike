package Shrike::Driver::DBI;

use Moose;
use DBI;
use YAML;

has table   => ( is => 'ro', isa => 'Str'                                  );
has columns => ( is => 'ro', isa => 'ArrayRef[Str]', default => sub { [] } );
has dsn     => ( is => 'ro', isa => 'HashRef[Item]'                        );
has get_pk  => ( is => 'ro', isa => 'CodeRef'                              );

has primary_key => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
);

has dbh     => (
    is      => 'rw',
    isa     => 'Item',
    lazy    => 1,
    default => sub {
        my $dsn = shift->dsn;
        DBI->connect($dsn->{data_source}, $dsn->{user}, $dsn->{password});
    },
);

sub insert {
    my $driver = shift;
    ## XXX verify these args
    my ($model, $data, $pk) = @_;

    ## by lack of PK management yet
#    $model->user_id( int rand 100000 );

    my $dbh          = $driver->dbh;
    my $table        = $driver->table;
    my $columns      = join ', ', @{ $driver->columns };
    my $placeholders = join ', ', (('?') x scalar @{ $driver->columns });

    ## could be prepare cached and stored in the class?
    my $stmt = "INSERT INTO $table ($columns) VALUES ($placeholders)";
    my @values = map { $data->{$_} } @{ $driver->columns };
    warn Dump { $stmt => \@values } ;
    my $sth = $dbh->prepare( $stmt );
    $sth->execute(@values);
    $sth->finish;

    ## trick...
    #$model->pk([ map { $data->{$_} } @{$driver->primary_key} ]);
    return 1;
}

sub get {
    my $driver = shift;
    my ($model_class, $pk) = @_;

    my @bind;
    my %fetch;
    for (@{ $driver->columns }) {
        push @bind, \$fetch{$_};
    }

    my $dbh      = $driver->dbh;
    my $table    = $driver->table;
    my $columns  = join ', ', @{ $driver->columns };
    my $pk_where = join ' AND ', map { "$_ = ?" } @{ $driver->primary_key };

    ## could be prepare_cached too and store on the object
    my $stmt = "SELECT $columns FROM $table WHERE $pk_where";
    warn Dump { $stmt => $pk };
    my $sth = $dbh->prepare( $stmt );
    $sth->execute(@$pk);
    $sth->bind_columns(undef, @bind);
    my $not_fetched = ! $sth->fetch;
    $sth->finish;
    return $not_fetched ? undef : \%fetch;
}

## might want to factor that with get(), get is a degenated
## case of get_multi
sub get_multi {
    my $driver = shift;
    my ($model_class, $pks) = @_;

    my $dbh      = $driver->dbh;
    my $table    = $driver->table;
    my @pk_col   = @{ $driver->primary_key };
    my $columns  = join ', ', @{ $driver->columns };

    # mysql
    #my $stmt = "SELECT $columns FROM $table WHERE $pk IN ($IN)";
    my @defined_pks = grep { defined } @$pks;
    my $pk_where    = '(' . ( join ' AND ', map { "$_ = ?" } @pk_col ) . ")";
    my $pk_wheres   = join ' OR ', ($pk_where) x scalar @defined_pks;
    my $stmt        = "SELECT $columns FROM $table WHERE $pk_wheres";
    warn Dump { $stmt => \@defined_pks };

    my @bind;
    my %fetch;
    for (@{ $driver->columns }) {
        push @bind, \$fetch{$_};
    }

    my $sth = $dbh->prepare( $stmt );
    # Does execute understand [], [] in the IN ((),()) case?
    my @execute;
    for (@defined_pks) {
        push @execute, @$_;
    }
    $sth->execute(@execute);
    $sth->bind_columns(undef, @bind);

    my %hashed_results;
    while ($sth->fetch) {
        my @key = @fetch{ @pk_col };
        ## might harmlessly collapse identical results
        $hashed_results{ join ":", @key } = { %fetch };
    }
    $sth->finish;

    ## we need to keep the same order in the results
    my @results;
    for my $pk (@$pks) {
        push @results, defined $pk ? $hashed_results{ join ":", @$pk } : undef;
    }

    return \@results;
}

## transformer
#    my @changed  = keys %{ $session->dirty_objects->{$model} || {} }; 

sub update {
    my $driver = shift;
    my ($model_class, $data, $pk) = @_;

    my $dbh      = $driver->dbh;
    my $table    = $driver->table;
    my @changed  = keys %$data;
    my $columns  = join ', ',    @{ $driver->columns };
    my $pk_where = join ' AND ', map { "$_ = ?" } @{ $driver->primary_key };
    my $set      = join ', ',    map { "$_ = ?" } @changed;

    my @changed_tuple = map { $data->{$_} } @changed;

    my $stmt = "UPDATE $table SET $set WHERE $pk_where";
    my $sth = $dbh->prepare( $stmt );
    my @bind = (@changed_tuple, @$pk);
    warn Dump { $stmt => \@bind };
    $sth->execute(@bind);
    $sth->finish;
    return 1;
}

1;

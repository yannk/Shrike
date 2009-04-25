package Shrike::Map;
use Carp;
use Moose;

has class    => ( is => 'ro', isa => 'Str'                           );
has driver   => ( is => 'ro', isa => 'Item'                          );
has mapper   => ( is => 'ro', isa => 'Shrike::Mapper', weak_ref => 1 );

has inflator => (
    is => 'ro',
    isa => 'Shrike::Inflator',
    handles => ['inflate'],
);

has deflator => (
    is => 'ro',
    isa => 'Shrike::Deflator',
    handles => ['deflate'],
);

has pk_generator => (
    is => 'ro',
    isa => 'Shrike::PK',
    handles => {
        generate_pk => 'generate',
    },
);

sub get {
    my $map = shift;
    my ($session, $model_class, $pk, @args) = @_;
    my $driver = $map->driver;
    my $data = $driver->get(@_);
    return unless $data;
    my $model = $map->inflate($data, $model_class);
    $model->pk($pk);
    return $model;
}

sub get_multi {
    my $map = shift;
    my ($session, $model_class, $pks, @args) = @_;
    my $driver = $map->driver;
    my $data_list = $driver->get_multi(@_);
    return [] unless $data_list;
    my $inflator = $map->inflator;
    my $inflate = $inflator->can('inflate');
    croak "Can't inflate because I don't have an inflator" unless $inflate;

    my @models;
    my $i = -1;
    for (@$data_list) {
        $i++;
        unless (defined $_) {
            push @models, undef;
            next;
        }
        push @models, $inflate->($inflator, $_, $model_class);
        $models[-1]->pk( $pks->[$i] );
    }
    return \@models;
    #return [ map { $inflate->($inflator, $_, $model_class) } @$data_list ];
}

sub insert {
    my $map = shift;
    my ($session, $model, @args) = @_;
    my $data = $map->deflate($model)
        or croak "Cannot deflate $model";
    my $model_class = ref $model; 
    my $pk = $map->generate_pk($model);
    $map->driver->insert($session, $model_class, $data, $pk, @args); 
    $model->pk($pk);
    return 1;
}

sub replace {
    my $map = shift;
    my ($session, $model, @args) = @_;
    my $data = $map->deflate($model)
        or croak "Cannot deflate $model";
    my $model_class = ref $model; 
    my $pk = $model->pk;
    return $map->driver->replace($session, $model_class, $data, $pk, @args); 
}

## XXX dilemna on update,
## though it's fine for some driver to do attribute changes (dbi)
## it might not be the case for others (memcached), which stratgy to choose?
## - take the cost of deflating?
## - take the cost of fetching the data in the cache and update it?
## simple solution, update() = delete of the cache key. Should be
## configurable.
sub update {
    my $map = shift;
    my ($session, $model, @args) = @_;
    my $data = $map->deflate($model)
        or croak "Cannot deflate $model";
    my $model_class = ref $model; 
    my $pk = $model->pk;
    return $map->driver->update($session, $model_class, $data, $pk, @args); 
}

sub delete {
    my $map = shift;
    my ($session, $model, @args) = @_;
    my $model_class = ref $model; 
    my $pk = $model->pk;
    return $map->driver->delete($session, $model_class, $pk, @args); 
}

no Moose;
1;

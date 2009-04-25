package Shrike::Session;
use Moose;
use Carp;
use Scalar::Util 'weaken';
use MooseX::AttributeHelpers;

has mapper => ( is => 'rw', isa => 'Item', required => 1 );

has in_store => (
    is => 'rw',
    isa => 'HashRef[Item]',
    default => sub { {} },
);

has in_memory => (
    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef[Item]',
    default => sub { [] },
    provides => {
        push  => 'add_to_memory',
        shift => 'next_in_memory',
    },
); 

has dirty_objects => (
    metaclass => 'Collection::Hash',
    is => 'rw',
    isa => 'HashRef[Item]',
    default => sub { {} },
    provides => {
        exists    => 'is_dirty',
        keys      => 'maps',
        get       => 'dirty',
        set       => 'mark_dirty',
        delete    => 'mark_as_synced',
    }
);

## there are objects that I'll need to test before issuing an insert
## because maybe they already existed? At least we should have an option
## to allow that

=head1 NAME

Shrike::Session - Responsible for maintaining the state of the dialog between
objects and stores.

=head1 SYNOPSIS

    use Shrike::Session;

    $session = Shrike::Session->new(mapper => $mapper);
    $session->add(@objects);
    $session->delete($object);

    $session->abort;
    # - or -
    $session->sync

=head1 METHODS

=head2 add($model, )

=cut

sub add {
    my $session = shift;
    my $model   = shift;

    croak "don't know how to map $model"
        unless $session->mapper->has_map_for(ref $model);

    ## grep { $seen++ } ?
    use Carp; warn Carp::longmess("ADD $model");
    $session->add_to_memory($model);
    $session->bind($model);
    return;
}

sub bind {
    my $session = shift;
    my $model   = shift;
    $model->{__shrike_session} = $session;
    weaken $model->{__skrike_session};
    return 1;
}

sub sync {
    my $session = shift;

    my $mapper = $session->mapper;

    for my $model_class (keys %{ $session->in_store }) {
        warn "update $model_class";
        my $map = $mapper->map_for($model_class);
        for my $model (values %{ $session->in_store->{$model_class} }) {
            my $dirty = $session->is_dirty($model);
            warn "Updating $model $dirty";
            next unless $session->is_dirty($model);
            $map->update($session, $model);
            ## XXX check success failure of the update
            $session->mark_as_synced($model);
        }
    }

    ## delete from the list of ephemeral and insert object
    use YAML; warn "GOT in memomry "  . scalar @{ $session->in_memory };
    while (my $model = $session->next_in_memory) {
        #use YAML; warn Dump $model;
        my $model_class = ref $model;
        my $map = $mapper->map_for($model_class);
        warn "insert $model => $map";
        $map->insert($session, $model);
        ## add the object to the persistent list
        $session->in_store->{$model_class}->{$model->pk_str} = $model;
        weaken $session->in_store->{$model_class}->{$model->pk_str};
        $session->mark_as_synced($model);
    }
    ## XXX delete case
    return 1;
}

sub get {
    my $session = shift;
    my $model_class = shift;
    my @args = @_;

    my $map = $session->mapper->map_for($model_class)
        or Carp::croak("No map to get from $model_class");
    my $model = $map->get($session, $model_class, @args)
        or return;

    ## now, we know about this object, let's make a note of it
    $session->in_store->{$model_class}->{$model->pk_str} = $model;
    $session->bind($model);
    return $model;
}

sub get_multi {
    my $session = shift;
    my $model_class = shift;
    my @args = @_;

    my $map = $session->mapper->map_for($model_class)
        or Carp::croak("No map to get_multi from $model_class");
    my $models = $map->get_multi($session, $model_class, @args);

    ## now, we know about this object, let's make a note of it
    for my $model (@$models) {
        $session->in_store->{$model_class}->{$model->pk_str} = $model;
        $session->bind($model);
    }
    return $models;
}

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

no Moose;
"Put something smart here"

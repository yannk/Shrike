package Shrike::Mapper;
use Carp;
use Moose;
use MooseX::AttributeHelpers;
use Shrike::Map;
use Sub::Install;

has maps => ( 
    metaclass => 'Collection::Hash',
    is => 'rw',
    isa => 'HashRef[Shrike::Map]',
    default => sub { {} },
    provides => {
        exists    => 'has_map_for',
        #keys      => 'all_maps',
        get       => 'map_for',
        set       => 'set_map_for',
        delete    => 'remove_map_for',
    }
);

=head1 NAME

Shrike::Mapper - Maps classes to drivers.

=head1 SYNOPSIS

Mapper defines how classes are mapped to drivers.

    use Shrike::Mapper;

    $mapper = Shrike::Mapper->new;
    $mapper->map( $class => $driver, $inflator, $deflator);

=head1 DESCRIPTION


=head1 METHODS

=head2 map($class, $driver, $inflator, $deflator) 

Create a map that binds a C<$class> to its C<$driver> and methods
of transformation: C<$inflator> and C<$deflator>

=cut 

sub map {
    my $mapper = shift;
    my ($model_class, $driver, $pk_generator, $inflator, $deflator) = @_;

    croak "There is already a map for $model_class"
        if $mapper->has_map_for($model_class);

    my $meta = $model_class->can('meta')
        or croak "There is no meta for $model_class";

    my $meta_class = $meta->($model_class);
    my %attributes = %{ $meta_class->get_attribute_map };
    for (keys %attributes) {
        $meta_class->add_after_method_modifier(
            $_ => $mapper->after_has_changed($_)
        );
    }
    $mapper->export_methods($model_class, $driver);
    my $map = Shrike::Map->new(
        class        => $model_class,
        driver       => $driver,
        pk_generator => $pk_generator,
        inflator     => $inflator,
        deflator     => $deflator,
        mapper       => $mapper,  # used?
    );
    $mapper->set_map_for($model_class => $map);
    return $map;
}

sub after_has_changed {
    my $mapper = shift;
    my $attr = shift;
    return sub {
        my $instance = shift;
        return unless @_;
        my $value = shift;
        warn "Changing $instance $attr to '$value'";
        ## need to clean up after the end of the session
        my $session = $instance->{__shrike_session};
        if ($session) {
            $session->mark_dirty($instance, $attr);
        }
        else {
            warn "Object is probably not mapped yet";
        }
        return;
    }
}

sub export_methods {
    my $class = shift;
    my ($model_class, $driver) = @_;

    my $pk = sub {
        my $model = shift;
        if (@_) {
            $model->{__pk} = shift;
        }
        return $model->{__pk} || [];

    };
    Sub::Install::install_sub({
        code => $pk,
        into => $model_class,
        as   => 'pk',
    });
    Sub::Install::install_sub({
        code => sub {
            return join ":", @{ shift->pk || [] };
        },
        into => $model_class,
        as   => 'pk_str',
    });
}

=head1 AUTHOR

Yann Kerhervé, C<< <yannk at cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yann Kerhervé, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut



"The Hegemony Consul sat on the balcony of his ebony spaceship...";

package Reaction::UI::Controller::Collection;

use strict;
use warnings;
use base 'Reaction::UI::Controller';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::ListView';
use aliased 'Reaction::UI::ViewPort::Object';

has 'model_name'      => (isa => 'Str', is => 'rw', required => 1);
has 'collection_name' => (isa => 'Str', is => 'rw', required => 1);

has action_viewport_map  => (isa => 'HashRef', is => 'rw', lazy_build => 1);
has action_viewport_args => (isa => 'HashRef', is => 'rw', lazy_build => 1);

sub _build_action_viewport_map {
  return {
          list => ListView,
          view => Object,
         };
}

sub _build_action_viewport_args {
  return { };
}

sub base :Action :CaptureArgs(0) {
  my ($self, $c) = @_;
}

#XXX candidate for futre optimization, should cache reader?
sub get_collection {
  my ($self, $c) = @_;
  my $model = $c->model( $self->model_name );
  my $attr  = $model->meta->find_attribute_by_name( $self->collection_name );
  my $reader = $attr->get_read_method;
  return $model->$reader;
}

sub list :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;
  $c->forward(basic_page => [{ collection => $self->get_collection($c) }]);
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
  my ($self, $c, $key) = @_;
  my $object = $self->get_collection($c)->find($key);
  confess "Object? what object?" unless $object; # should be a 404.
  $c->stash(object => $object);
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  $c->forward(basic_page => [{object => $c->stash->{object}}]);
}

sub basic_page : Private {
  my ($self, $c, $vp_args) = @_;
  my $action_name = $c->stack->[-2]->name;
  return $self->push_viewport
    (
     $self->action_viewport_map->{$action_name},
     %{ $vp_args || {} },
     %{ $self->action_viewport_args->{$action_name} || {} },
    );
}

1;

package Reaction::UI::CRUDController;

use strict;
use warnings;
use base 'Reaction::UI::Controller';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::ListView';
use aliased 'Reaction::UI::ViewPort::ActionForm';
use aliased 'Reaction::UI::ViewPort::ObjectView';

has 'model_name'      => (isa => 'Str', is => 'rw', required => 1);
has 'collection_name' => (isa => 'Str', is => 'rw', required => 1);

has action_viewport_map  => (isa => 'HashRef', is => 'rw', lazy_build => 1);
has action_viewport_args => (isa => 'HashRef', is => 'rw', lazy_build => 1);

sub build_action_viewport_map {
  return {
          list       => ListView,
          view       => ObjectView,
          create     => ActionForm,
          update     => ActionForm,
          delete     => ActionForm,
          delete_all => ActionForm,
         };
}

sub build_action_viewport_args {
  my $self = shift;
  return { list =>
           { action_prototypes =>
             [ { label => 'Create', action => sub {
                   [ '', 'create',    $_[1]->req->captures ] } },
               { label => 'Delete all', action => sub {
                   [ '', 'delete_all', $_[1]->req->captures ] } },
             ],
             Entity =>
             { action_prototypes =>
               [ { label => 'View', action => sub {
                     [ '', 'view', [ @{$_[1]->req->captures},   $_[0]->__id ] ] } },
                 { label => 'Edit', action => sub {
                     [ '', 'update', [ @{$_[1]->req->captures}, $_[0]->__id ] ] } },
                 { label => 'Delete', action => sub {
                     [ '', 'delete', [ @{$_[1]->req->captures}, $_[0]->__id ] ] } },
               ],
             },
           },
         };
}

sub base :Action :CaptureArgs(0) {
  my ($self, $c) = @_;
}

sub get_collection {
  my ($self, $c) = @_;
  my $model = $c->model( $self->model_name );
  my $attr  = $model->meta->find_attribute_by_name( $self->collection_name );
  my $reader = $attr->get_read_method;
  return $model->$reader;
}

sub get_model_action {
  my ($self, $c, $name, $target) = @_;

  if ($target->can('action_for')) {
    return $target->action_for($name, ctx => $c);
  }

  #can we please kill this already?
  my $model_name = "Action::${name}".$self->model_name;
  my $model = $c->model($model_name);
  confess "no such Model $model_name" unless $model;
  return $model->new(target_model => $target, ctx => $c);
}

sub list :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;

  $self->push_viewport(
                       $self->action_viewport_map->{list},
                       %{ $self->action_viewport_args->{list} || {} },
                       collection => $self->get_collection($c)
                      );
}

sub create :Chained('base') :PathPart('create') :Args(0) {
  my ($self, $c) = @_;
  my $action = $self->get_model_action($c, 'Create', $self->get_collection($c));
  $self->push_viewport
    (
     $self->action_viewport_map->{create},
     %{ $self->action_viewport_args->{create} || {} },
     action => $action,
     next_action => 'list',
     on_apply_callback => sub { $self->after_create_callback($c => @_); },
    );
}

sub delete_all :Chained('base') :PathPart('delete_all') :Args(0) {
  my ($self, $c) = @_;
  my $action = $self->get_model_action($c, 'DeleteAll', $self->get_collection($c));
  $self->push_viewport
    (
     $self->action_viewport_map->{delete_all},
     %{ $self->action_viewport_args->{delete_all} || {} },
     action => $action,
     next_action => 'list',
    );
}

sub after_create_callback {
  my ($self, $c, $vp, $result) = @_;
  return $self->redirect_to
    ( $c, 'update', [ @{$c->req->captures}, $result->id ] );
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
  my ($self, $c, $key) = @_;
  my $object :Stashed = $self->get_collection($c)->find($key);
  confess "Object? what object?" unless $object; # should be a 404.
}

sub update :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $object :Stashed;
  my $action = $self->get_model_action($c, 'Update', $object);
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->push_viewport
    (
     $self->action_viewport_map->{update},
     %{ $self->action_viewport_args->{update} || {} },
     action => $action,
     next_action => [ $self, 'redirect_to', 'list', \@cap ]
  );
}

sub delete :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $object :Stashed;
  my $action = $self->get_model_action($c, 'Delete', $object);
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->push_viewport
    (
     $self->action_viewport_map->{delete},
     %{ $self->action_viewport_args->{delete} || {} },
     action => $action,
     next_action => [ $self, 'redirect_to', 'list', \@cap ]
  );
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $object :Stashed;
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->push_viewport
    (
     $self->action_viewport_map->{view},
     %{ $self->action_viewport_args->{view} || {} },
     object => $object,
    );
}

1;

package Reaction::UI::CRUDController;

use strict;
use warnings;
use base 'Reaction::UI::Controller';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::ListView';
use aliased 'Reaction::UI::ViewPort::ActionForm';
use aliased 'Reaction::UI::ViewPort::ObjectView';

has 'model_base' => (isa => 'Str', is => 'rw', required => 1);
has 'model_name' => (isa => 'Str', is => 'rw', required => 1);

has 'ActionForm_class' => (isa => 'Str', is => 'rw', required => 1,
                           lazy => 1, default => sub{ ActionForm });
has 'ListView_class'   => (isa => 'Str', is => 'rw', required => 1,
                           lazy => 1, default => sub{ ListView });
has 'ObjectView_class' => (isa => 'Str', is => 'rw', required => 1,
                           lazy => 1, default => sub{ ObjectView });

sub base :Action :CaptureArgs(0) {
  my ($self, $c) = @_;
}

sub get_collection {
  my ($self, $c) = @_;
  #this sucks and should be fixed
  return $c->model(join('::', $self->model_base, $self->model_name));
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
    $self->ListView_class,
    collection => $self->get_collection($c)
  );
}

sub create :Chained('base') :PathPart('create') :Args(0) {
  my ($self, $c) = @_;
  my $action = $self->get_model_action($c, 'Create', $self->get_collection($c));
  $self->push_viewport(
    $self->ActionForm_class,
    action => $action,
    next_action => 'list',
    on_apply_callback => sub { $self->after_create_callback($c => @_); },
  );
}

sub after_create_callback {
  my ($self, $c, $vp, $result) = @_;
  return $self->redirect_to(
           $c, 'update', [ @{$c->req->captures}, $result->id ]
         );
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
  $self->push_viewport(
    $self->ActionForm_class,
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
  $self->push_viewport(
    $self->ActionForm_class,
    action => $action,
    next_action => [ $self, 'redirect_to', 'list', \@cap ]
  );
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $object :Stashed;
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->push_viewport(
    $self->ObjectView_class,
    object => $object
  );
}

1;

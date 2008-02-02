package Reaction::UI::Controller::Collection::CRUD;

use strict;
use warnings;
use base 'Reaction::UI::Controller::Collection';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Action';

sub _build_action_viewport_map {
  my $map = shift->next::method(@_);
  map{ $map->{$_} = Action } qw/create update delete delete_all/;
  return $map;
}

sub _build_action_viewport_args {
  my $args = shift->next::method(@_);
  $args->{list} =
    { action_prototypes =>
      [ { label => 'Create', action => sub {
            [ '', 'create',    $_[1]->req->captures ] } },
        { label => 'Delete all', action => sub {
            [ '', 'delete_all', $_[1]->req->captures ] } },
      ],
      Member =>
      { action_prototypes =>
        [ { label => 'View', action => sub {
              [ '', 'view', [ @{$_[1]->req->captures},   $_[0]->__id ] ] } },
          { label => 'Edit', action => sub {
              [ '', 'update', [ @{$_[1]->req->captures}, $_[0]->__id ] ] } },
          { label => 'Delete', action => sub {
              [ '', 'delete', [ @{$_[1]->req->captures}, $_[0]->__id ] ] } },
        ],
      },
    };
  return $args;
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

sub create :Chained('base') :PathPart('create') :Args(0) {
  my ($self, $c) = @_;
  my $vp_args = {
                 next_action => 'list',
                 on_apply_callback => sub { $self->after_create_callback($c => @_); },
                };
  $self->basic_model_action( $c, [$vp_args]);
}

sub delete_all :Chained('base') :PathPart('delete_all') :Args(0) {
  my ($self, $c) = @_;
  $self->basic_model_action( $c,  [{ next_action => 'list'}]);
}

sub after_create_callback {
  my ($self, $c, $vp, $result) = @_;
  return $self->redirect_to
    ( $c, 'update', [ @{$c->req->captures}, $result->id ] );
}

sub update :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  my $vp_args = { next_action => [ $self, 'redirect_to', 'list', \@cap ]};
  $self->basic_model_action( $c, [$vp_args]);
}

sub delete :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  my $vp_args = { next_action => [ $self, 'redirect_to', 'list', \@cap ]};
  $self->basic_model_action( $c, [$vp_args]);
}

sub basic_model_action {
  my ($self, $c, $vp_args) = @_;

  my $target = exists $c->stash->{object} ?
    $c->stash->{object} : $self->get_collection($c);

  my $cat_action_name = $c->stack->[-1]->name;
  my $im_action_name  = join('', (map{ ucfirst } split('_', $cat_action_name)));
  return $self->push_viewport
    (
     $self->action_viewport_map->{$cat_action_name},
     model => $self->get_model_action($c, $im_action_name, $target),
     %{ $vp_args || {} },
     %{ $self->action_viewport_args->{$cat_action_name} || {} },
    );
}

1;

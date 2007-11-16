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

sub _build_action_viewport_map {
  return {
          list       => ListView,
          view       => ObjectView,
          create     => ActionForm,
          update     => ActionForm,
          delete     => ActionForm,
          delete_all => ActionForm,
         };
}

sub _build_action_viewport_args {
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

#XXX candidate for futre optimization, should cache reader?
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
  $c->forward(basic_page => { collection => $self->get_collection($c) });
}

sub create :Chained('base') :PathPart('create') :Args(0) {
  my ($self, $c) = @_;
  my $vp_args = {
                 next_action => 'list',
                 on_apply_callback => sub { $self->after_create_callback($c => @_); },
                };
  $c->forward( basic_model_action => $vp_args);
}

sub delete_all :Chained('base') :PathPart('delete_all') :Args(0) {
  my ($self, $c) = @_;
  $c->forward(basic_model_action => { next_action => 'list'});
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
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  my $vp_args = { next_action => [ $self, 'redirect_to', 'list', \@cap ]};
  $c->forward(basic_model_action => $vp_args);
}

sub delete :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  my $vp_args = { next_action => [ $self, 'redirect_to', 'list', \@cap ]};
  $c->forward(basic_model_action => $vp_args);
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $object :Stashed;
  $c->forward(basic_page => {object => $object});
}




sub basic_model_action :Private {
  my ($self, $c, $vp_args) = @_;

  my $target = exists $c->stash->{object} ?
    $c->stash->{object} : $self->get_collection($c);

  my $cat_action_name = $c->stack->[-2]->name;
  my $im_action_name  = join('', (map{ uc } split('_', $cat_action_name)));
  return $self->push_viewport
    (
     $self->action_viewport_map->{$cat_action_name},
     action => $self->get_model_action($c, $im_action_name, $target),
     %{ $vp_args || {} },
     %{ $self->action_viewport_args->{$cat_action_name} || {} },
    );
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

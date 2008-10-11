package Reaction::UI::Controller::Collection;

use strict;
use warnings;
use base 'Reaction::UI::Controller';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Collection::Grid';
use aliased 'Reaction::UI::ViewPort::Object';

has model_name => (isa => 'Str', is => 'rw', required => 1);
has collection_name => (isa => 'Str', is => 'rw', required => 1);

has action_viewport_map => (isa => 'HashRef', is => 'rw', lazy_build => 1);
has action_viewport_args => (isa => 'HashRef', is => 'rw', lazy_build => 1);

has default_member_actions => (
  isa => 'ArrayRef',
  is => 'rw',
  lazy_build => 1
);

has default_collection_actions => (
  isa => 'ArrayRef',
  is => 'rw',
  lazy_build => 1
);

sub _build_default_member_actions { ['view'] }

sub _build_default_collection_actions { [] }

sub _build_action_viewport_map {
  my $self = shift;
  my %map;
  $map{list} = Grid;
  $map{view} = Object if grep {$_ eq 'view'} @{$self->default_member_actions};
  return \%map;
}

sub _build_action_viewport_args {
  my $self = shift;
  my $args = { list => { Member => {} } };

  my $m_protos = $args->{list}{Member}{action_prototypes} = {};
  for my $action_name( @{ $self->default_member_actions }){
    my $label = ucfirst(join(' ', split(/_/, $action_name)));
    my $proto = $self->_build_member_action_prototype($label, $action_name);
    $m_protos->{$action_name} = $proto;
  }

  my $c_protos = $args->{list}{action_prototypes} = {};
  for my $action_name( @{ $self->default_collection_actions }){
    my $label = ucfirst(join(' ', split(/_/, $action_name)));
    my $proto = $self->_build_collection_action_prototype($label, $action_name);
    $c_protos->{$action_name} = $proto;
  }

  return $args;
}

sub _build_member_action_prototype {
  my ($self, $label, $action_name) = @_;
  return {
    label => $label,
    uri => sub {
      my $action = $self->action_for($action_name);
      $_[1]->uri_for($action, [ @{$_[1]->req->captures}, $_[0]->__id ]);
    },
  };
}

sub _build_collection_action_prototype {
  my ($self, $label, $action_name) = @_;
  return {
    label => $label,
    uri => sub {
      my $action = $self->action_for($action_name);
      $_[1]->uri_for($action, $_[1]->req->captures);
    },
  };
}

#XXX candidate for futre optimization, should cache reader?
sub get_collection {
  my ($self, $c) = @_;
  my $model = $c->model( $self->model_name );
  my $collection = $self->collection_name;
  if( my $meth = $model->can( $collection ) ){
    return $model->$meth;
  } elsif ( my $attr = $model->meta->find_attribute_by_name($collection) ) {
    my $reader = $attr->get_read_method;
    return $model->$reader;
  }
  confess "Failed to find collection $collection";
}

sub base :Action :CaptureArgs(0) {
  my ($self, $c) = @_;
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
  my ($self, $c, $key) = @_;
  my $object = $self->get_collection($c)->find($key);
  $c->detach("/error_404") unless $object;
  $c->stash(object => $object);
}

sub list :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;
  $self->basic_page($c, { collection => $self->get_collection($c) });
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  $self->basic_page($c, { model => $c->stash->{object} });
}

sub basic_page {
  my ($self, $c, $vp_args) = @_;
  my $action_name = $c->stack->[-1]->name;
  my $vp = $self->action_viewport_map->{$action_name},
  my $args = $self->merge_config_hashes
    (
     $vp_args || {},
     $self->action_viewport_args->{$action_name} || {} ,
    );
  return $self->push_viewport($vp, %$args);
}

1;

__END__;

=head1 NAME

Reaction::UI::Controller

=head1 DESCRIPTION

Controller class used to make displaying collections easier.
Inherits from L<Reaction::UI::Controller>.

=head1 ATTRIBUTES

=head2 model_name

The name of the model this controller will use as it's data source. Should be a
name that can be passed to C<$C-E<gt>model>

=head2 collection_name

The name of the collection whithin the model that this Controller will be
utilizing.

=head2 action_viewport_map

=over 4

=item B<_build_action_viewport_map> - Provided builder method, see METHODS

=item B<has_action_viewport_map> - Auto generated predicate

=item B<clear_action_viewport_map>- Auto generated clearer method

=back

Read-write lazy building hashref. The keys should match action names in the
Controller and the value should be the ViewPort class that this action should
use. See method C<basic_page> for more info.

=head2 action_viewport_args

Read-write lazy building hashref. Additional ViewPort arguments for the action
named as the key in the controller.  See method C<basic_page> for more info.

=over 4

=item B<_build_action_viewport_args> - Provided builder method, see METHODS

=item B<has_action_viewport_args> - Auto generated predicate

=item B<clear_action_viewport_args>- Auto generated clearer method

=back

=head1 METHODS

=head2 get_collection $c

Returns an instance of the collection this controller uses.

=head2 _build_action_viewport_map

Provided builder for C<action_viewport_map>. Returns a hash with two items:

    list => 'Reaction::UI::ViewPort::ListView',
    view => 'Reaction::UI::ViewPort::Object',

=head2 _build_action_viewport_args

Returns an empty hashref.

=head2 basic_page $c, \%vp_args

Accepts two arguments, context, and a hashref of viewport arguments. It will
automatically determine the action name using the catalyst stack and call
C<push_viewport> with the ViewPort class name contained in the
C<action_viewport_map> with a set of options determined by merging C<$vp_args>
and the arguments contained in C<action_viewport_args>, if any.

=head1 ACTIONS

=head2 base

Chain link, no-op.

=head2 list

Chain link, chained to C<base>. C<list> fetches the collection for the model
and calls C<basic_page> with a single argument, C<collection>.

The default ViewPort for this action is C<Reaction::UI::ViewPort::ListView> and
can be changed by altering the C<action_viewport_map> attribute hash.

=head2 object

Chain link, chained to C<base>, captures one argument, 'id'. Attempts to find
a single object by searching for a member of the current collection which has a
Primary Key or Unique constraint matching that argument. If the object is found
it is stored in the stash under the C<object> key.

=head2 view

Chain link, chained to C<object>. Calls C<basic page> with one argument,
C<model>, which contains an instance of the object fetched by the C<object>
action link.

The default ViewPort for this action is C<Reaction::UI::ViewPort::Object> and
can be changed by altering the C<action_viewport_map> attribute hash.

=head1 SEE ALSO

L<Reaction::UI::Controller>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

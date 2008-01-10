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

#XXX candidate for futre optimization, should cache reader?
sub get_collection {
  my ($self, $c) = @_;
  my $model = $c->model( $self->model_name );
  my $attr  = $model->meta->find_attribute_by_name( $self->collection_name );
  my $reader = $attr->get_read_method;
  return $model->$reader;
}

sub base :Action :CaptureArgs(0) {
  my ($self, $c) = @_;
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
  my ($self, $c, $key) = @_;
  my $object = $self->get_collection($c)->find($key);
  confess "Object? what object?" unless $object; # should be a 404.
  $c->stash(object => $object);
}

sub list :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;
  $c->forward(basic_page => [{ collection => $self->get_collection($c) }]);
}

sub view :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  $c->forward(basic_page => [{ model => $c->stash->{object} }]);
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


__END__;

=head1 NAME

Reaction::UI::Widget::Controller

=head1 DESCRIPTION

Controller class used to make displaying collections easier.
Inherits from L<Reaction::UI::Controller>.

=head1 ATTRIBUTES

=head2 model_name

The name of the model this controller will use as it's data source. Should be a name
that can be passed to C<$C-E<gt>model>

=head2 collection_name

The name of the collection whithin the model that this Controller will be utilizing.

=head2 action_viewport_map

=over 4

=item B<_build_action_viewport_map> - Provided builder method, see METHODS

=item B<has_action_viewport_map> - Auto generated predicate

=item B<clear_action_viewport_map>- Auto generated clearer method

=back

Read-write lazy building hashref. The keys should match action names in the Controller
and the value should be the ViewPort class that this action should use.
 See method C<basic_page> for more info.

=head action_viewport_args

Read-write lazy building hashref. Additional ViewPort arguments for the action named
as the key in the controller.  See method C<basic_page> for more info.

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

=head1 ACTIONS

=head2 base

Chain link, no-op.

=head2 list

Chain link, chained to C<base> forwards to basic page passing one custom argument,
C<collection> which includes an instance of the current collection.

The default ViewPort for this action is C<Reaction::UI::ViewPort::ListView> and can be
changed by altering the C<action_viewport_map> attribute hash.

=head2 object

Chain link, chained to C<base>, captures one argument, 'id'. Attempts to find a single
object by searching for a member of the current collection which has a Primary Key or
Unique constraint matching that argument. If the object is found it is stored in the
 stash under the C<object> key.

=head2 view

Chain link, chained to C<object>. Forwards to C<basic page> with one custom vp argument
 of C<object>, which is the object located in the previous chain link of the same name.

The default ViewPort for this action is C<Reaction::UI::ViewPort::Object> and can be
changed by altering the C<action_viewport_map> attribute hash.

=head2 basic_page

Private action, accepts one argument, a hashref of viewport arguments (C<$vp_args>).
 It will automatically determine the action name using the catalyst stack and call
C<push_viewport> with the ViewPort class name contained in the C<action_viewport_map>
and arguments of C<$vp_args> and the arguments contained in C<action_viewport_args>,
if any.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

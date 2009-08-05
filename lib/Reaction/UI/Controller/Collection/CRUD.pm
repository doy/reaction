package Reaction::UI::Controller::Collection::CRUD;

use strict;
use warnings;
use base 'Reaction::UI::Controller::Collection';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Action';
use aliased 'Reaction::UI::ViewPort::ListView';

sub _build_action_viewport_map {
  my $self = shift;
  my $map = $self->next::method(@_);
  $map->{list} = ListView if exists $map->{list};

  #my %allowed = map { $_ => undef }
  #  ( @{$self->default_member_actions}, @{$self->default_collection_actions} );
  my @local_actions = qw/create update delete delete_all/;
  #$map->{$_} = Action for grep { exists $allowed{$_} } @local_actions;

  $map->{$_} = Action for @local_actions;
  return $map;
}

sub _build_default_member_actions {
  [ @{shift->next::method(@_)}, qw/update delete/ ];
}

sub _build_default_collection_actions {
  [ @{shift->next::method(@_)}, qw/create delete_all/ ];
}

sub get_model_action {
  my ($self, $c, $name, $target) = @_;
  return $target->action_for($name, ctx => $c);
}
sub create :Chained('base') :PathPart('create') :Args(0) {
  my ($self, $c) = @_;
  my $apply = sub { $self->after_create_callback( @_) };
  my $close = sub { $self->on_create_close_callback( @_) };
  my $vp_args = {
    target => ($c->stash->{collection} || $self->get_collection($c)),
    on_apply_callback => $self->make_context_closure($apply),
    on_close_callback => $self->make_context_closure($close),
  };
  $self->basic_model_action( $c, $vp_args);
}

sub delete_all :Chained('base') :PathPart('delete_all') :Args(0) {
  my ($self, $c) = @_;
  my $close = sub { $self->on_delete_all_close_callback( @_) };
  $self->basic_model_action( $c, {
    target => ($c->stash->{collection} || $self->get_collection($c)),
    on_close_callback => $self->make_context_closure($close),
  });
}

sub on_delete_all_close_callback {
  my($self, $c) = @_;
  $self->redirect_to($c, 'list');
}

sub after_create_callback {
  my ($self, $c, $vp, $result) = @_;
  return $self->redirect_to
    ( $c, 'update', [ @{$c->req->captures}, $result->id ] );
}

sub on_create_close_callback {
  my($self, $c, $vp) = @_;
  $self->redirect_to( $c, 'list' );
}

sub update :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $close = sub { $self->on_update_close_callback( @_) };
  my $vp_args = {
    on_close_callback => $self->make_context_closure($close),
  };
  $self->basic_model_action( $c, $vp_args);
}

sub on_update_close_callback {
  my($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->redirect_to($c, 'list', \@cap);
}

sub delete :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  my $close = sub { $self->on_delete_close_callback( @_) };
  my $vp_args = {
    on_close_callback => $self->make_context_closure($close),
  };
  $self->basic_model_action( $c, $vp_args);
}

sub on_delete_close_callback {
  my($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures};
  pop(@cap); # object id
  $self->redirect_to($c, 'list', \@cap);
}

sub basic_model_action {
  my ($self, $c, $vp_args) = @_;
  my $stash = $c->stash;
  my $target = delete $vp_args->{target};
  $target ||= ($stash->{object} || $stash->{collection} || $self->get_collection($c));

  my $action_name = join('', map{ ucfirst } split('_', $c->stack->[-1]->name));
  my $model = $self->get_model_action($c, $action_name, $target);
  return $self->basic_page($c, { model => $model, %{$vp_args||{}} });
}

1;

__END__

=head1 NAME

Reaction::UI::Controller::Collection::CRUD - Basic CRUD functionality for Reaction::InterfaceModel data

=head1 DESCRIPTION

Controller class which extends L<Reaction::UI::Controller::Collection> to 
provide basic Create / Update / Delete / DeleteAll actions.

Building on the base of the Collection controller this controller allows you to
easily create complex and highly flexible CRUD functionality for your 
InterfaceModel models by providing a simple way to render and process your
custom InterfaceModel Actions and customize built-ins.

=head1 METHODS

=head2 get_model_action $c, $action_name, $target_im

Get an instance of the C<$action_name> 
L<InterfaceModel::Action|Reaction::InterfaceModel::Action> for model C<$target>
This action is suitable for passing to an 
C<Action|Reaction::UI::ViewPort::Action> viewport

=head2 after_create_callback $c, $vp, $result

When a <create> action is applied, move the user to the new object's,
C<update> page.

=head2 basic_model_action $c, \%vp_args

Extension to C<basic_page> which automatically instantiates an 
L<InterfaceModel::Action|Reaction::InterfaceModel::Action> with the right
data target using C<get_model_action>

=head2 _build_action_viewport_map

Map C<create>, C<update>, C<delete> and C<delete_all> to use the
L<Action|Reaction::UI::ViewPort::Action> viewport by default and have C<list>
use L<ListView|Reaction::UI::ViewPort::ListView> by default.

=head2 _build_default_member_actions

Add C<update> and C<delete> to the list of default actions.

=head2 _build_default_collection_actions

Add C<create> and C<delete_all> to the list of default actions.

=head1 ACTIONS

=head2 create

Chaned to C<base>. Create a new member of the collection represented by 
this controller. By default it attaches the C<after_create_callback> to
DWIM after apply operations.

See L<Create|Reaction::InterfaceModel::Action::DBIC::ResultSet::Create>
 for more info.

=head2 delete_all

Chained to B<base>, delete all the members of the B<collection>. In most cases
this is very much like a C<TRUNCATE> operation.

See L<DeleteAll|Reaction::InterfaceModel::Action::DBIC::ResultSet::DeleteAll>
 for more info.

=head2 update

Chained to C<object>, update a single object.

See L<Update|Reaction::InterfaceModel::Action::DBIC::Result::Update>
 for more info.

=head2 delete

Chained to C<object>, delete a single object.

See L<Delete|Reaction::InterfaceModel::Action::DBIC::Result::Delete>
 for more info.

=head1 SEE ALSO

L<Reaction::UI::Controller::Collection>, L<Reaction::UI::Controller>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

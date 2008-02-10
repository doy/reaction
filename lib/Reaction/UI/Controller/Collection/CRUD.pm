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
  $self->basic_model_action( $c, $vp_args);
}

sub delete_all :Chained('base') :PathPart('delete_all') :Args(0) {
  my ($self, $c) = @_;
  $self->basic_model_action( $c,  { next_action => 'list'});
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
  $self->basic_model_action( $c, $vp_args);
}

sub delete :Chained('object') :Args(0) {
  my ($self, $c) = @_;
  #this needs a better solution. currently thinking about it
  my @cap = @{$c->req->captures}; 
  pop(@cap); # object id
  my $vp_args = { next_action => [ $self, 'redirect_to', 'list', \@cap ]};
  $self->basic_model_action( $c, $vp_args);
}

sub basic_model_action {
  my ($self, $c, $vp_args) = @_;

  my $target = exists $c->stash->{object} ?
    $c->stash->{object} : $self->get_collection($c);

  my $action_name = join('', map{ ucfirst } split('_', $c->stack->[-1]->name));
  my $model = $self->get_model_action($c, $action_name, $target);
  return $self->basic_page($c, { model => $model, %{$vp_args||{}} });
}

1;

__END__

=head1 NAME

Reaction::UI::Controller::CRUD - Basic CRUD functionality for Reaction::InterfaceModel data

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
C<Action|Reaction::UI::ViewPort::Action> viewport by default.

=head2 _build_action_viewport_args

Add action_prototypes to the C<list> action so that action links render correctly in L<ListView|Rection::UI::ViewPort::Listview>.

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

Chained to C<object>, deletee a single object.


See L<Delete|Reaction::InterfaceModel::Action::DBIC::Result::Delete>
 for more info.

=head1 SEE ALSO

L<Reaction::UI::Controller::Collection>, L<Reaction::UI::Controller>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

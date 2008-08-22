package Reaction::UI::ViewPort::Object::Mutable;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Object';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Text';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Array';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::String';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Number';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Integer';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Boolean';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Password';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::DateTime';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::ChooseOne';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::ChooseMany';

use aliased 'Reaction::UI::ViewPort::Field::Mutable::File';
#use aliased 'Reaction::UI::ViewPort::Field::Mutable::TimeRange';

use MooseX::Types::Moose qw/Int/;
use Reaction::Types::Core qw/NonEmptySimpleStr/;

use namespace::clean -except => [ qw(meta) ];
extends Object;
with 'Reaction::UI::ViewPort::Action::Role::OK';

has model => (
  is => 'ro',
  isa => 'Reaction::InterfaceModel::Action',
  required => 1
 );

has changed => (
  is => 'rw',
  isa => Int,
  reader => 'is_changed',
  default => sub{0}
 );

#this has to fucking go. it BLOWS.
has method => (
  is => 'rw',
  isa => NonEmptySimpleStr,
  default => sub { 'post' }
 );

sub can_apply {
  my ($self) = @_;
  foreach my $field ( @{ $self->fields } ) {
    return 0 if $field->needs_sync;
    # if e.g. a datetime field has an invalid value that can't be re-assembled
    # into a datetime object, the action may be in a consistent state but
    # not synchronized from the fields; in this case, we must not apply
  }
  return $self->model->can_apply;
}

sub do_apply {
  shift->model->do_apply;
}

after apply_child_events => sub {
  # interrupt here because fields will have been updated
  my ($self) = @_;
  $self->sync_action_from_fields;
};

sub sync_action_from_fields {
  my ($self) = @_;
  foreach my $field (@{$self->fields}) {
    $field->sync_to_action; # get the field to populate the $action if possible
  }
  $self->model->sync_all;
  foreach my $field (@{$self->fields}) {
    $field->sync_from_action; # get errors from $action if applicable
  }
}

sub _build_fields_for_type_Num {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Number, %$args);
}

sub _build_fields_for_type_Int {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Integer, %$args);
}

sub _build_fields_for_type_Bool {
  my ($self,  $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Boolean, %$args);
}

sub _build_fields_for_type_Reaction_Types_Core_SimpleStr {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_Reaction_Types_File_File {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => File, %$args);
}

sub _build_fields_for_type_Str {
  my ($self, $attr, $args) = @_;
  if ($attr->has_valid_values) { # There's probably a better way to do this
    $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
  } else {
    $self->_build_simple_field(attribute => $attr, class => Text, %$args);
  }
}

sub _build_fields_for_type_Reaction_Types_Core_Password {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Password, %$args);
}

sub _build_fields_for_type_Reaction_Types_DateTime_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

sub _build_fields_for_type_Enum {
  my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
}

#this needs to be fixed. somehow. beats the shit our of me. really.
#implements build_fields_for_type_Reaction_InterfaceModel_Object => as {
sub _build_fields_for_type_DBIx_Class_Row {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
}

sub _build_fields_for_type_ArrayRef {
  my ($self, $attr, $args) = @_;
  if ($attr->has_valid_values) {
    $self->_build_simple_field(attribute => $attr, class => ChooseMany,  %$args);
  } else {
    $self->_build_simple_field
      (
       attribute => $attr,
       class     => Array,
       layout    => 'field/mutable/hidden_array',
       %$args);
  }
}

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Reaction::UI::ViewPort::Object::Mutable

=head1 SYNOPSIS

  use aliased 'Reaction::UI::ViewPort::Object::Mutable';

  $self->push_viewport(Mutable,
    layout => 'register',
    model => $action,
    next_action => [ $self, 'redirect_to', 'accounts', $c->req->captures ],
    ctx => $c,
    field_order => [
      qw / contact_title company_name email address1 address2 address3
           city country post_code telephone mobile fax/ ],
  );

=head1 DESCRIPTION

This subclass of L<Reaction::UI::ViewPort::Object> is used for rendering a
collection of C<Reaction::UI::ViewPort::Field::Mutable::*> objects for user editing.

=head1 ATTRIBUTES

=head2 model

L<Reaction::InterfaceModel::Action>

=head2 ok_label

Default: 'ok'

=head2 apply_label

Default: 'apply'

=head2 close_label_close

Default: 'close'

=head2 close_label_cancel

This label is only shown when C<changed> is true.

Default: 'cancel'

=head2 fields

=head2 can_apply

=head2 can_close

=head2 changed

Returns true if a field has been edited.

=head2 next_action

=head2 on_apply_callback

CodeRef.

=head1 METHODS

=head2 ok

Calls C<apply>, and then C<close> if successful.

=head2 close

Pop viewport and proceed to C<next_action>.

=head2 apply

Attempt to save changes and update C<changed> attribute if required.

=head1 SEE ALSO

L<Reaction::UI::ViewPort::Object>

L<Reaction::UI::ViewPort>

L<Reaction::InterfaceModel::Action>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


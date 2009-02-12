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

use namespace::clean -except => [ qw(meta) ];
extends Object;

#this her for now. mutable fields need an action to build correctly
has model => (
  is => 'ro',
  isa => 'Reaction::InterfaceModel::Action',
  required => 1,
);

sub is_modified {
  my $self = shift;
  foreach my $field (@{$self->fields}) {
    return 1 if $field->is_modified;
  }
  return 0;
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

sub _build_fields_for_type_MooseX_Types_Common_String_SimpleStr {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_MooseX_Types_Common_String_Password {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Password, %$args);
}

sub _build_fields_for_type_MooseX_Types_DateTime_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

sub _build_fields_for_type_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Reaction::UI::ViewPort::Object::Mutable

=head1 SYNOPSIS

=head1 DESCRIPTION

This subclass of L<Reaction::UI::ViewPort::Object> is used for rendering a
collection of C<Reaction::UI::ViewPort::Field::Mutable::*> objects for user editing.

=head1 ATTRIBUTES

=head2 model

L<Reaction::InterfaceModel::Action>

=head1 METHODS

=head2  _build_fields_for_type_Num

=head2  _build_fields_for_type_Int

=head2  _build_fields_for_type_Bool

=head2  _build_fields_for_type_Reaction_Types_Core_SimpleStr

=head2  _build_fields_for_type_Reaction_Types_File_File

=head2  _build_fields_for_type_Str

=head2  _build_fields_for_type_Reaction_Types_Core_Password

=head2  _build_fields_for_type_Reaction_Types_DateTime_DateTime

=head2  _build_fields_for_type_Enum

=head2  _build_fields_for_type_DBIx_Class_Row

=head2  _build_fields_for_type_ArrayRef

=head1 SEE ALSO

L<Reaction::UI::ViewPort::Object>

L<Reaction::UI::ViewPort>

L<Reaction::InterfaceModel::Action>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


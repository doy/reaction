package Reaction::UI::ViewPort::DisplayField;

use Reaction::Class;

class DisplayField is 'Reaction::UI::ViewPort', which {

  has name => (
    isa => 'Str', is => 'rw', required => 1
  );

  has object => (
    isa => 'Reaction::InterfaceModel::Object',
    is => 'ro', required => 0, predicate => 'has_object',
  );

  has attribute => (
    isa => 'Reaction::Meta::InterfaceModel::Object::ParameterAttribute',
    is => 'ro', predicate => 'has_attribute',
  );

  has value => (
    is => 'rw', lazy_build => 1, trigger_adopt('value'),
  );

  has label => (isa => 'Str', is => 'rw', lazy_build => 1);

  implements BUILD => as {
    my ($self) = @_;
    if (!$self->has_attribute != !$self->has_object) {
        confess "Should have both object and attribute or neither"; }
  };

  implements _build_label => as {
    my ($self) = @_;
    return join(' ', map { ucfirst } split('_', $self->name));
  };

  implements _build_value => as {
    my ($self) = @_;
    if ($self->has_attribute) {
      my $reader = $self->attribute->get_read_method;
      return $self->object->$reader;
    }
    return '';
  };

};

1;

=head1 NAME

Reaction::UI::ViewPort::DisplayField

=head1 DESCRIPTION

Base class for displaying non user-editable fields.

=head1 ATTRIBUTES

=head2 name

=head2 object

L<Reaction::InterfaceModel::Object>

=head2 attribute

L<Reaction::Meta::InterfaceModel::Object::ParameterAttribute>

=head2 value

=head2 label

User friendly label, by default is based on the name.

=head1 SEE ALSO

L<Reaction::UI::ViewPort>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

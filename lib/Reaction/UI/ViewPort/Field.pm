package Reaction::UI::ViewPort::Field;

use Reaction::Class;

class Field is 'Reaction::UI::ViewPort', which {

  has name => (
    isa => 'Str', is => 'rw', required => 1
  );

  has action => (
    isa => 'Reaction::InterfaceModel::Action',
    is => 'ro', required => 0, predicate => 'has_action',
  );

  has attribute => (
    isa => 'Reaction::Meta::InterfaceModel::Action::ParameterAttribute',
    is => 'ro', predicate => 'has_attribute',
  );

  has value => (
    is => 'rw', lazy_build => 1, trigger_adopt('value'),
    clearer => 'clear_value',
  );

  has needs_sync => (
    isa => 'Int', is => 'rw', default => 0
  );

  has label => (isa => 'Str', is => 'rw', lazy_build => 1);

  has message => (
    isa => 'Str', is => 'rw', required => 1, default => sub { '' }
  );

  implements BUILD => as {
    my ($self) = @_;
    if (!$self->has_attribute != !$self->has_action) {
      confess "Should have both action and attribute or neither";
    }
  };

  implements build_label => as {
    my ($self) = @_;
    my $label = join(' ', map { ucfirst } split('_', $self->name));
    # print STDERR "Field " . $self->name . " has label '$label'\n";
    return $label;
  };

  implements build_value => as {
    my ($self) = @_;
    if ($self->has_attribute) {
      my $reader = $self->attribute->get_read_method;
      my $predicate = $self->attribute->predicate;
      if (!$predicate || $self->action->$predicate) {
        return $self->action->$reader;
      }
    }
    return '';
  };

  implements adopt_value => as {
    my ($self) = @_;
    $self->needs_sync(1) if $self->has_attribute;
  };

  implements sync_to_action => as {
    my ($self) = @_;
    return unless $self->needs_sync && $self->has_attribute && $self->has_value;
    my $attr = $self->attribute;
    if (my $tc = $attr->type_constraint) {
      my $value = $self->value;
      if ($tc->has_coercion) {
        $value = $tc->coercion->coerce($value);
      }
      my $error = $tc->validate($self->value);
      if (defined $error) {
        $self->message($error);
        return;
      }
    }
    my $writer = $attr->get_write_method;
    confess "No writer for attribute" unless defined($writer);
    $self->action->$writer($self->value);
    $self->needs_sync(0);
  };

  implements sync_from_action => as {
    my ($self) = @_;
    return unless !$self->needs_sync && $self->has_attribute;
    $self->message($self->action->error_for($self->attribute)||'');
  };

  override accept_events => sub { ('value', super()) };

};

1;

=head1 NAME

Reaction::UI::ViewPort::Field

=head1 DESCRIPTION

This viewport is the base class for all field types.

=head1 ATTRIBUTES

=head2 name

=head2 action

L<Reaction::InterfaceModel::Action>

=head2 attribute

L<Reaction::Meta::InterfaceModel::Action::ParameterAttribute>

=head2 value

=head2 needs_sync

=head2 label

User friendly label, by default is based on the name.

=head2 message

Optional string relating to the field.

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort>

=head2 L<Reaction::UI::ViewPort::DisplayField>

=head2 L<Reaction::UI::ViewPort::Field::Boolean>

=head2 L<Reaction::UI::ViewPort::Field::ChooseMany>

=head2 L<Reaction::UI::ViewPort::Field::ChooseOne>

=head2 L<Reaction::UI::ViewPort::Field::DateTime>

=head2 L<Reaction::UI::ViewPort::Field::File>

=head2 L<Reaction::UI::ViewPort::Field::HiddenArray>

=head2 L<Reaction::UI::ViewPort::Field::Number>

=head2 L<Reaction::UI::ViewPort::Field::Password>

=head2 L<Reaction::UI::ViewPort::Field::String>

=head2 L<Reaction::UI::ViewPort::Field::Text>

=head2 L<Reaction::UI::ViewPort::Field::TimeRange>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::ViewPort::Field;

use Reaction::Class;
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::Meta::InterfaceModel::Object::ParameterAttribute';

class Field is 'Reaction::UI::ViewPort', which {

  has value        => (is => 'rw', lazy_build => 1);
  has name         => (is => 'rw', isa => 'Str', lazy_build => 1);
  has label        => (is => 'rw', isa => 'Str', lazy_build => 1);
  has value_string => (is => 'rw', isa => 'Str', lazy_build => 1);

  has model     => (is => 'ro', isa => Object,             required => 1);
  has attribute => (is => 'ro', isa => ParameterAttribute, required => 1);

  implements _build_name => as { shift->attribute->name };

  implements _build_label => as {
    join(' ', map { ucfirst } split('_', shift->name));
  };

  implements _build_value => as {
    my ($self) = @_;
    my $reader = $self->attribute->get_read_method;
    return $self->model->$reader;
  };

  implements _model_has_value => as {
    my ($self) = @_;
    my $predicate = $self->attribute->predicate;

    if (!$predicate || $self->model->$predicate
        || ($self->attribute->is_lazy
            && !$self->attribute->is_lazy_fail)
      ) {
      # either model attribute has a value now or can build it
      return 1;
    }
    return 0;
  };

  implements _build_value_string => as {
    my ($self) = @_;
    # XXX need the defined test because the IM lazy builds from
    # the model and DBIC can have nullable fields and DBIC doesn't
    # have a way to tell us that doesn't force value inflation (extra
    # SELECTs for belongs_to) so basically we're screwed.
    return ($self->_model_has_value && defined($self->value)
              ? $self->_value_string_from_value
              : $self->_empty_string_value);
  };

  implements _value_string_from_value => as {
    shift->value;
  };

  implements _empty_string_value => as { '' };

  implements value_is_required => as {
    shift->attribute->is_required;
  };

};

1;
__END__;

=head1 NAME

Reaction::UI::ViewPort::Field

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 model

=head2 attribute

=head2 value

=head2 name

=head2 label

=head2 value_string

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

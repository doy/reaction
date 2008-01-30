package Reaction::UI::ViewPort::Field;

use Reaction::Class;
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::Meta::InterfaceModel::Object::ParameterAttribute';

class Field is 'Reaction::UI::ViewPort', which {

  has value        => (is => 'rw', lazy_fail => 1);
  has name         => (is => 'rw', isa => 'Str', lazy_build => 1);
  has label        => (is => 'rw', isa => 'Str', lazy_build => 1);
  has value_string => (is => 'rw', isa => 'Str', lazy_build => 1);

  has model     => (is => 'ro', isa => Object,             required => 1);
  has attribute => (is => 'ro', isa => ParameterAttribute, required => 1);

  implements adopt_value => as {};

  implements _build_name => as { shift->attribute->name };

  implements _build_value_string => as {
    my($self) = @_;
    return $self->has_value? $self->value : '';
  };

  implements _build_label => as {
    join(' ', map { ucfirst } split('_', shift->name));
  };

  implements BUILD => as {
    my($self) = @_;
    my $reader = $self->attribute->get_read_method;
    my $predicate = $self->attribute->predicate;

    if (!$predicate || $self->model->$predicate
        || ($self->attribute->is_lazy
            && !$self->attribute->is_lazy_fail)
      ) {
      my $value = $self->model->$reader;
      if ( $self->attribute->is_required ) {
        $self->value($value) if defined $value;
      }
      else {
        $self->value($value);
      }
    }
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

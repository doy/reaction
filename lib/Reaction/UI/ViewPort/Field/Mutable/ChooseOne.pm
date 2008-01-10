package Reaction::UI::ViewPort::Field::Mutable::ChooseOne;

use Reaction::Class;

class ChooseOne is 'Reaction::UI::ViewPort::Field', which {

  does 'Reaction::UI::ViewPort::Field::Role::Mutable';
  does 'Reaction::UI::ViewPort::Field::Role::Choices';

  around value => sub {
    my $orig = shift;
    my $self = shift;
    return $orig->($self) unless @_;
    my $value = shift;
    if (defined $value) {
      $value = $self->str_to_ident($value) if (!ref $value);
      my $checked = $self->attribute->check_valid_value($self->model, $value);
      confess "${value} is not a valid value" unless defined($checked);
      $value = $checked;
    }
    $orig->($self, $value);
  };

  implements _build_value_string => as {
    my $self = shift;
    $self->obj_to_name($self->value->{value});
  };

  implements is_current_value => as {
    my ($self, $check_value) = @_;
    my $our_value = $self->value;
    return unless ref($our_value);
    $check_value = $self->obj_to_str($check_value) if ref($check_value);
    return $self->obj_to_str($our_value) eq $check_value;
  };


};

1;

package Reaction::UI::ViewPort::Field::Mutable::Boolean;

use Reaction::Class;

class Boolean is 'Reaction::UI::ViewPort::Field::Boolean', which{
  does 'Reaction::UI::ViewPort::Field::Role::Mutable::Simple';

  implements adopt_value_string => as {
    my ($self) = @_;
    $self->value($self->value_string);
  };

  implements BUILD => as {
    my($self) = @_;
    $self->value(0) unless $self->_model_has_value;
  };

};

1;

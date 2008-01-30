package Reaction::UI::ViewPort::Field::Mutable::Boolean;

use Reaction::Class;

class Boolean is 'Reaction::UI::ViewPort::Field::Boolean', which{
  does 'Reaction::UI::ViewPort::Field::Role::Mutable';

  implements BUILD => as {
    my($self) = @_;
    $self->value(0) unless $self->has_value;
  };

};

1;

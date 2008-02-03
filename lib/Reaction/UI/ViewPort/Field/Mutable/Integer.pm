package Reaction::UI::ViewPort::Field::Mutable::Integer;

use Reaction::Class;

class Integer is 'Reaction::UI::ViewPort::Field::Integer', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable::Simple';

  implements adopt_value_string => as {
    my ($self) = @_;
    $self->value($self->value_string);
  };

};

1;

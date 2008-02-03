package Reaction::UI::ViewPort::Field::Mutable::String;

use Reaction::Class;

class String is 'Reaction::UI::ViewPort::Field::String', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable::Simple';

  implements adopt_value_string => as {
    my ($self) = @_;
    $self->value($self->value_string);
  };

};

1;

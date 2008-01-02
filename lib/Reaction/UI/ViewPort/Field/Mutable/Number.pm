package Reaction::UI::ViewPort::Field::Mutable::Number;

use Reaction::Class;

class Number is 'Reaction::UI::ViewPort::Field::Number', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable';
};

1;

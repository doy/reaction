package Reaction::UI::ViewPort::Field::Mutable::Text;

use Reaction::Class;

class Text is 'Reaction::UI::ViewPort::Field::Text', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable';
};

1;

package Reaction::UI::ViewPort::Field::Boolean;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

class Boolean, is Field, which {
  has '+value' => (isa => 'Bool');
};

1;

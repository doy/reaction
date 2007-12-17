package Reaction::UI::ViewPort::Field::Number;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

class Number is Field, which {
  has '+value' => (isa => 'Num');
};

1;

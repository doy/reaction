package Reaction::UI::ViewPort::Field::Integer;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

class Integer is Field, which {
  has '+value' => (isa => 'Int');
};

1;

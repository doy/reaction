package Reaction::UI::ViewPort::Field::String;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

class String is Field, which {
  has '+value' => (isa => 'Str');
};

1;

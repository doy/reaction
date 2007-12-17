package Reaction::UI::ViewPort::Field::Text;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

class Text is Field, which {
  has '+value' => (isa => 'Str');
};

1;

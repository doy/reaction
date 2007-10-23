package Reaction::UI::ViewPort::DisplayField::String;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::DisplayField';

class String is DisplayField, which {
  has '+value' => (isa => 'Str');
  #has '+layout' => (default => 'displayfield/string');
};

1;

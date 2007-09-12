package Reaction::UI::ViewPort::DisplayField::Text;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::DisplayField';

class Text is DisplayField, which {
  has '+value' => (isa => 'Str');
  has '+layout' => (default => 'displayfield/text');
};

1;

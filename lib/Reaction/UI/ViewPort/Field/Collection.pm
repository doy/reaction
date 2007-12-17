package Reaction::UI::ViewPort::Field::Collection;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::Field::Array';

class Collection is Array, which {

  #XXX
  override _build_value => sub {
    return [super()->members];
  };

};

1;

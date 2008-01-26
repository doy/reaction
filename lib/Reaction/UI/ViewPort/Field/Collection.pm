package Reaction::UI::ViewPort::Field::Collection;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::Field::Array';

class Collection is Array, which {

  #XXX
  override _build_value => sub {
    my $collection = super();
    return blessed($collection) ? [$collection->members] : $collection;
  };

};

1;

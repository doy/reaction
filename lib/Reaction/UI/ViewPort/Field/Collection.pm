package Reaction::UI::ViewPort::Field::Collection;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::Field::Array';

class Collection is Array, which {

  has value => (
    is => 'rw', lazy_build => 1,
    isa => 'Reaction::InterfaceModel::Collection'
  );

  implements _build_value_names => as {
    my $self = shift;
    my $meth = $self->value_map_method;
    my @names = map { blessed($_) ? $_->$meth : $_ } $self->value->members;
    return [ sort @names ];
  };

};

1;

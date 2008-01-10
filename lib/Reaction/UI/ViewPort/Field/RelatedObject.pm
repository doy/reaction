package Reaction::UI::ViewPort::Field::RelatedObject;

use Reaction::Class;
use Scalar::Util 'blessed';

class RelatedObject is 'Reaction::UI::ViewPort::Field', which {

  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  implements _build_value_string => as {
    my $self = shift;
    my $meth = $self->value_map_method;
    my $value = $self->value;
    return blessed($value) ? $value->$meth : $value;
  };

};

1;
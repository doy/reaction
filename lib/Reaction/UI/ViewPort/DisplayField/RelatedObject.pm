package Reaction::UI::ViewPort::DisplayField::RelatedObject;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::DisplayField';

class RelatedObject is DisplayField, which {

  has '+layout' => (default => 'displayfield/value_string');

  has value_string => (isa => 'Str', is => 'ro', lazy_build => 1);

  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  implements build_value_string => as {
    my $self = shift;
    my $meth = $self->value_map_method;
    my $value = $self->value;
    return blessed $value ? $value->$meth : $value;
  };

};

1;

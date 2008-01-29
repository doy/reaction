package Reaction::UI::ViewPort::Field::RelatedObject;

use Reaction::Class;
use Scalar::Util 'blessed';

class RelatedObject is 'Reaction::UI::ViewPort::Field', which {

  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  around _value_string_from_value => sub {
    my $orig = shift;
    my $self = shift;
    my $meth = $self->value_map_method;
    return $self->$orig(@_)->$meth;
  };

};

1;

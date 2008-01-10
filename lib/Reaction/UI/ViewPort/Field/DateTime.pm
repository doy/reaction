package Reaction::UI::ViewPort::Field::DateTime;

use Reaction::Class;
use Reaction::Types::DateTime;
use aliased 'Reaction::UI::ViewPort::Field';

class DateTime is Field, which {
  has '+value' => (isa => 'DateTime');

  has value_string_default_format => (
    isa => 'Str', is => 'rw', required => 1, default => sub { "%F %H:%M:%S" }
  );

  implements _build_value_string => as {
    my $self = shift;
    # XXX
    #<mst> aha, I know why the fucker's lazy
    #<mst> it's because if value's calculated
    #<mst> it needs to be possible to clear it
    #<mst> eval { $self->value } ... is probably the best solution atm
    my $value = eval { $self->value };
    return '' unless $self->has_value;
    my $format = $self->value_string_default_format;
    return $value->strftime($format) if $value;
    return '';
  };

};

1;

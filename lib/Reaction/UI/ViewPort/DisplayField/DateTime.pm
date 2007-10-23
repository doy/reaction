package Reaction::UI::ViewPort::DisplayField::DateTime;

use Reaction::Class;
use Reaction::Types::DateTime;
use aliased 'Reaction::UI::ViewPort::DisplayField';

class DateTime is DisplayField, which {
  has '+value' => (isa => 'DateTime');
  #has '+layout' => (default => 'displayfield/value_string');

  has value_string => (isa => 'Str',  is => 'rw', lazy_build => 1);

  has value_string_default_format => (
    isa => 'Str', is => 'rw', required => 1, default => sub { "%F %H:%M:%S" }
  );

  implements build_value_string => as {
    my $self = shift;
    my $value = eval { $self->value };
    return '' unless $self->has_value;
    my $format = $self->value_string_default_format;
    return $value->strftime($format) if $value;
    return '';
  };

};

1;

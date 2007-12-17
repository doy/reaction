package Reaction::UI::ViewPort::Field::Array;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::Field';

class Array is Field, which {
  has '+value' => (isa => 'ArrayRef');

  has value_names => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  implements _build_value_names => as {
    my $self = shift;
    my @all = @{ $self->value || []};
    my $meth = $self->value_map_method;
    my @names = map { blessed($_) ? $_->$meth : $_ } @all;
    return [ sort @names ];
  };

};

1;

package Reaction::UI::ViewPort::DisplayField::List;

use Reaction::Class;
use Scalar::Util 'blessed';
use aliased 'Reaction::UI::ViewPort::DisplayField';

class List is DisplayField, which {
  has '+value' => (isa => 'ArrayRef');
  #has '+layout' => (default => 'displayfield/list');

  has value_names => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);

  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  override build_value => sub {
    return super() || [];
  };

  implements build_value_names => as {
    my $self = shift;
    my @all = @{$self->value||[]};
    my $meth = $self->value_map_method;
    my @names = map { blessed $_ ? $_->$meth : $_ } @all;
    return [ sort @names ];
  };

};

1;

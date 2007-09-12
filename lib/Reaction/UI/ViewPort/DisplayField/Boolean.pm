package Reaction::UI::ViewPort::DisplayField::Boolean;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::DisplayField';

class Boolean, is DisplayField, which {
    has '+value' => (isa => 'Bool');
    has '+layout' => (default => 'displayfield/value_string');

    has value_string => (isa => 'Str', is => 'rw', lazy_build => 1);

    has value_string_format =>
        (isa => 'HashRef', is => 'rw', required => 1,
         default => sub { {true => 'Yes', false => 'No'} }
  );

  implements build_value_string => as {
    my $self = shift;
    my $val = $self->value;
    if(!defined $val || $val eq "" || "$val" eq '0'){
        return $self->value_string_format->{false};
    } elsif("$val" eq '1'){
        return $self->value_string_format->{true};
    } else{  #this will hopefully never happen
        confess "Not supporting some type of Bool value";
    }
  };

};

1;

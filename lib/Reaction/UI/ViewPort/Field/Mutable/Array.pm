package Reaction::UI::ViewPort::Field::Mutable::Array;

use Reaction::Class;

class Array is 'Reaction::UI::ViewPort::Field::Array', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable';

  around value => sub {
    my $orig = shift;
    my $self = shift;
    return $orig->($self) unless @_;
    my $value = defined $_[0] ? $_[0] || [];
    $orig->($self, (ref $value eq 'ARRAY' ? $value : [ $value ]));
    $self->sync_to_action;
  };
};

1;


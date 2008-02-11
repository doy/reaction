package Reaction::UI::ViewPort::Field::Role::Mutable::Simple;

use Reaction::Role;

use aliased 'Reaction::UI::ViewPort::Field::Role::Mutable';

role Simple which {

  does Mutable;

  has value_string => (
    is => 'rw', lazy_build => 1, trigger_adopt('value_string'),
    clearer => 'clear_value',
  );

  around value_string => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ && defined($_[0]) && !ref($_[0]) && $_[0] eq ''
        && !$self->value_is_required) {
      $self->clear_value;
      return undef;
    }
    return $self->$orig(@_);
  };

  # the user needs to implement this because, honestly, you're always going
  # to need to do something custom and the only common thing really is
  # "you probably set $self->value at the end"
  requires 'adopt_value_string';

  around accept_events => sub { ('value_string', shift->(@_)) };

};

1;

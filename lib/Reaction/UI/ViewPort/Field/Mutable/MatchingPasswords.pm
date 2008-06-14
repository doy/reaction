package Reaction::UI::ViewPort::Field::Mutable::MatchingPasswords;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Password';

class MatchingPasswords is Password, which {

  has check_value => (is => 'rw', isa => 'Str', );

  #maybe both check_value and value_string should have triggers ?
  #that way if one even happens before the other  it would still work?
  around adopt_value_string => sub {
    my $orig = shift;
    my ($self) = @_;
    return $orig->(@_) if $self->check_value eq $self->value_string;
    $self->message("Passwords do not match");
  };

  #order is important check_value should happen before value here ...
  #i don't like how this works, it's unnecessarily fragile, but how else ?
  around accept_events => sub { ('check_value', shift->(@_)) };

  around can_sync_to_action => sub {
    my $orig = shift;
    my ($self) = @_;
    return $orig->(@_) if $self->check_value eq $self->value_string;
    $self->message("Passwords do not match");
    return;
  };

};

1;

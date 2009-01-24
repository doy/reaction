package Reaction::UI::ViewPort::Field::Role::Mutable::Simple;

use Reaction::Role;

use aliased 'Reaction::UI::ViewPort::Field::Role::Mutable';

use namespace::clean -except => [ qw(meta) ];
with Mutable;

has value_string => (
  is => 'rw', lazy_build => 1, trigger_adopt('value_string'),
  clearer => 'clear_value',
);

has '+is_modified' => (default => 0);

around value_string => sub {
  my $orig = shift;
  my $self = shift;
  if (@_) {
    # recursive call. be VERY careful we don't go infinite here
    my $old = $self->value_string;
    my $new = $_[0];
    if ((defined $old xor defined $new) || (defined $old && $old ne $new)) {
      $self->_set_modified(1);
    } else {
      return;
    }
  }
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

around force_events => sub { (value_string => '', shift->(@_)) };



1;

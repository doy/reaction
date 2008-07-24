package Reaction::UI::ViewPort::Collection::Role::Order;

use Reaction::Role;

use namespace::clean -except => [ qw(meta) ];


has order_by      => (isa => 'Str', is => 'rw', trigger_adopt('order_by'));
has order_by_desc => (isa => 'Int', is => 'rw', trigger_adopt('order_by'), lazy_build => 1);
sub _build_order_by_desc { 0 };
sub adopt_order_by {
  shift->clear_current_collection;
};

around _build_current_collection => sub {
  my $orig = shift;
  my ($self) = @_;
  my $collection = $orig->(@_);
  my %attrs;

  #XXX DBICism that needs to be fixed
  if ($self->has_order_by) {
    $attrs{order_by} = $self->order_by;
    $attrs{order_by} .= ' DESC' if ($self->order_by_desc);
  }

  return $collection->where(undef, \%attrs);
};

around accept_events => sub { ('order_by', 'order_by_desc', shift->(@_)); };



1;

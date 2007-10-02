package Reaction::UI::ViewPort::GridView::Role::Order;

use Reaction::Role;

role Order, which {

  has order_by      => (isa => 'Str', is => 'rw', trigger_adopt('order_by'));
  has order_by_desc => (isa => 'Int', is => 'rw', trigger_adopt('order_by'), lazy_build => 1);

  around build_current_collection => sub {
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

};

1;

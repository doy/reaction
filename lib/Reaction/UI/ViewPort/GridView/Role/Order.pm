package Reaction::UI::ViewPort::GridView::Role::Order;

use Reaction::Role;

role Order, which {

  has order_by      => (isa => 'Str', is => 'rw', trigger_adopt('order_by'));
  has order_by_desc => (isa => 'Int', is => 'rw', trigger_adopt('order_by'), lazy_build => 1);

  before order_by => sub {
    if (@_ > 1) {
      my ($self, $val) = @_;
      confess "invalid column name for order_by"
        unless grep { $val eq $_ } $self->collection
                                        ->_source_resultset
                                        ->result_source
                                        ->columns;
    }
  };

  implements _build_order_by_desc => as { 0 };

  implements adopt_order_by => as {
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

};

1;

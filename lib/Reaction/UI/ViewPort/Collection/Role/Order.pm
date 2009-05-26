package Reaction::UI::ViewPort::Collection::Role::Order;

use Reaction::Role;

use namespace::clean -except => [ qw(meta) ];

has enable_order_by => (is => 'rw', isa => 'ArrayRef');
has coerce_order_by => (isa => 'HashRef', is => 'rw');

has order_by => (
  isa => 'Str',
  is => 'rw',
  trigger_adopt('order_by'),
  clearer => 'clear_order_by'
);

has order_by_desc => (
  isa => 'Int',
  is => 'rw',
  trigger_adopt('order_by'),
  lazy_build => 1
);

sub _build_order_by_desc { 0 }

sub adopt_order_by {
  shift->clear_current_collection;
}

sub can_order_by {
  my ($self,$order_by) = @_;
  return 1 unless $self->has_enable_order_by;
  return scalar grep { $order_by eq $_ } @{ $self->enable_order_by };
}

sub _order_search_attrs {
  my $self = shift;
  my %attrs;
  if ($self->has_order_by) {
    my $order_by = $self->order_by;
    if( $self->has_coerce_order_by ){
      $order_by = $self->coerce_order_by->{$order_by}
        if exists $self->coerce_order_by->{$order_by};
    }
    my $key = $self->order_by_desc ? '-desc' : '-asc';
    $attrs{order_by} = { $key => $order_by };
  }
  return \%attrs;
}

after clear_order_by => sub {
  my ($self) = @_;
  $self->order_by_desc(0);
  $self->clear_current_collection;
};

around _build_current_collection => sub {
  my $orig = shift;
  my ($self) = @_;
  my $collection = $orig->(@_);
  return $collection->where(undef, $self->_order_search_attrs);
};

around accept_events => sub { ('order_by', 'order_by_desc', shift->(@_)); };



1;

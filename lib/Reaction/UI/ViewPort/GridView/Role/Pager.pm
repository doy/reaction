package Reaction::UI::ViewPort::GridView::Role::Pager;

use Reaction::Role;

use aliased 'Reaction::InterfaceModel::Collection';

role Pager, which {

  has paged_collection => (isa => Collection, is => 'rw', lazy_build => 1);

  has pager    => (isa => 'Data::Page', is => 'rw', lazy_build => 1);
  has page     => (isa => 'Int', is => 'rw', lazy_build => 1, trigger_adopt('page'));
  has per_page => (isa => 'Int', is => 'rw', lazy_build => 1, trigger_adopt('page'));

  implements build_page     => as { 1  };
  implements build_per_page => as { 10 };

  implements build_pager => as { shift->paged_collection->pager };

  implements adopt_page => as {
    my ($self) = @_;
    $self->clear_paged_collection;
    $self->clear_pager;
  };

  around accept_events => sub { ('page', shift->(@_)); };

  implements build_paged_collection => sub {
    my ($self) = @_;
    my $collection = $self->current_collection;
    return $collection->where(undef, {rows => $self->per_page})->page($self->page);
  };

};

1;

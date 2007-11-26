package Reaction::UI::WidgetClass::_OVER;

use Reaction::Class;

class _OVER, which {

  has 'collection' => (is => 'ro', required => 1);

  implements BUILD => as {
    my ($self, $args) = @_;
    my $coll = $args->{collection};
    unless (ref $coll eq 'ARRAY' || (blessed($coll) && $coll->can('next'))) {
      confess _OVER."->new collection arg ${coll} is neither"
                   ." arrayref nor implements next()";
    }
  };

  implements 'each' => as {
    my ($self, $do) = @_;
    my $coll = $self->collection;
    if (ref $coll eq 'ARRAY') {
      foreach my $el (@$coll) {
        $do->($el);
      }
    } else {
      $coll->reset if $coll->can('reset');
      while (my $el = $coll->next) {
        $do->($el);
      }
    }
  };
};

1;

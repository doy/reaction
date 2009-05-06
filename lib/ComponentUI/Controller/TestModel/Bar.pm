package ComponentUI::Controller::TestModel::Bar;

use base 'Reaction::UI::Controller::Collection::CRUD';
use Reaction::Class;

__PACKAGE__->config(
  model_name => 'TestModel',
  collection_name => 'Bar',
  action => {
    base => { Chained => '/base', PathPart => 'testmodel/bar' },
    list => {
      ViewPort => {
        enable_order_by => [qw/name foo published_at/],
        coerce_order_by => { foo => ['foo.last_name', 'foo.first_name'] },
      }
    }
  },
);

sub get_collection {
  my ($self, $c) = @_;
  my $collection = $self->next::method($c);
  return $collection->where({}, { prefetch => 'foo' });
}

1;

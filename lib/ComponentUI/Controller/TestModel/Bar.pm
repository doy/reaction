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
        layout => 'bar/collection',
        member_class => 'Reaction::UI::ViewPort::Object',
        Member => { layout => 'bar/member' }
      }
    }
  },
);

sub get_collection {
  my ($self, $c) = @_;
  my $collection = $self->next::method($c);
  return $collection->where({}, { prefetch => 'foo' });
}

sub create :Chained('base') {
  my $self = shift;
  my ($c) = @_;
  my $action_vp = $self->next::method(@_);
  my $self_uri = $c->uri_for($self->action_for('create'));
  $action_vp->action($self_uri);
  return $action_vp;
}

1;

package # hide from PAUSE
  RTest::TestDB::Foo;

use DBIx::Class 0.07;

use base qw/DBIx::Class Reaction::Object/;
use Reaction::Class;

has 'id' => (isa => 'Int', is => 'ro', required => 1);
has 'first_name' => (isa => 'NonEmptySimpleStr', is => 'rw', required => 1);
has 'last_name' => (isa => 'NonEmptySimpleStr', is => 'rw', required => 1);
has 'baz_list' => (
  isa => 'ArrayRef', is => 'rw', required => 1,
  reader => 'get_baz_list', writer => 'set_baz_list'
);

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

__PACKAGE__->table('foo');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', size => 16, is_auto_increment => 1 },
  first_name => { data_type => 'varchar', size => 255 },
  last_name => { data_type => 'varchar', size => 255 },
);

sub display_name {
  my $self = shift;
  return join(' ', $self->first_name, $self->last_name);
}

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('links_to_baz_list' => 'RTest::TestDB::FooBaz', 'foo');
__PACKAGE__->many_to_many('baz_list' => 'links_to_baz_list' => 'baz');

{
  no warnings 'redefine';
  *get_baz_list = sub { [ shift->baz_list->all ] };
}

1;

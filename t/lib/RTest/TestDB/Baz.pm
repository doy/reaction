package # hide from PAUSE
  RTest::TestDB::Baz;

use DBIx::Class 0.07;

use base qw/DBIx::Class Reaction::Object/;
use Reaction::Class;

has 'id' => (isa => 'Int', is => 'ro', required => 1);
has 'name' => (isa => 'NonEmptySimpleStr', is => 'rw', required => 1);
has 'foo_list' => (isa => 'ArrayRef', is => 'ro', required => 1);

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

__PACKAGE__->table('baz');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', size => 16, is_auto_increment => 1 },
  name => { data_type => 'varchar', size => 255 },
);

sub display_name { shift->name; }

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('links_to_foo_list' => 'RTest::TestDB::FooBaz', 'baz');
__PACKAGE__->many_to_many('foo_list' => 'links_to_foo_list' => 'foo');

1;

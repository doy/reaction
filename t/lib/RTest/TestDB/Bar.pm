package # hide from PAUSE
  RTest::TestDB::Bar;

use DBIx::Class 0.07;

use base qw/DBIx::Class Reaction::Object/;
use Reaction::Class;
use Reaction::Types::DateTime;
use Reaction::Types::File;

has 'name' => (isa => 'NonEmptySimpleStr', is => 'rw', required => 1);
has 'foo' => (isa => 'RTest::TestDB::Foo', is => 'rw', required => 1);
has 'published_at' => (isa => 'DateTime', is => 'rw');
has 'avatar' => (isa => 'File', is => 'rw');

__PACKAGE__->load_components(qw/InflateColumn::DateTime Core/);

__PACKAGE__->table('bar');

__PACKAGE__->add_columns(
  name => { data_type => 'varchar', size => 255 },
  foo_id => { data_type => 'integer', size => 16 },
  published_at => { data_type => 'datetime', is_nullable => 1 },
  avatar => { data_type => 'blob', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('name');

__PACKAGE__->belongs_to(
  'foo' => 'RTest::TestDB::Foo',
  { 'foreign.id' => 'self.foo_id' }
);

1;

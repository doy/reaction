package # hide from PAUSE
  RTest::TestDB::Foo;

use base qw/DBIx::Class::Core/;
use metaclass 'Reaction::Meta::Class';
use Moose;

use MooseX::Types::Moose qw/ArrayRef Int/;
use Reaction::Types::Core qw/NonEmptySimpleStr/;

has 'id' => (isa => Int, is => 'ro', required => 1);
has 'first_name' => (isa => NonEmptySimpleStr, is => 'rw', required => 1);
has 'last_name' => (isa => NonEmptySimpleStr, is => 'rw', required => 1);
has 'baz_list' =>
  (
   isa => ArrayRef,
   required => 1,
   reader => 'get_baz_list',
   writer => 'set_baz_list'
);

use namespace::clean -except => [ 'meta' ];

__PACKAGE__->table('foo');

__PACKAGE__->add_columns(
  id => { data_type => 'integer', size => 16, is_auto_increment => 1 },
  first_name => { data_type => 'varchar', size => 255 },
  last_name => { data_type => 'varchar', size => 255 },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many('links_to_baz_list' => 'RTest::TestDB::FooBaz', 'foo');
__PACKAGE__->many_to_many('baz_list' => 'links_to_baz_list' => 'baz');

sub display_name {
  my $self = shift;
  return join(' ', $self->first_name, $self->last_name);
}

sub get_baz_list { [ shift->baz_list->all ] };

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;

package ComponentUI::TestModel::Baz;

use lib 't/lib';
use Reaction::InterfaceModel::DBIC::ObjectClass;

class Baz, which{
  domain_model '_baz_store' =>
    (isa => 'RTest::TestDB::Baz', inflate_result => 1,
     handles => ['display_name'],
     reflect => [qw(id name foo_list)],
    );

  reflect_actions
    (
     Create => { attrs =>[qw(name)] },
     Update => { attrs =>[qw(name)] },
     Delete => {},
    );
};

1;

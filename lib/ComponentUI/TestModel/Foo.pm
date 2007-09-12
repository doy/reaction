package ComponentUI::TestModel::Foo;

use lib 't/lib';
use Reaction::InterfaceModel::DBIC::ObjectClass;

class Foo, which{
  domain_model '_foo_store' =>
    (isa => 'RTest::TestDB::Foo', inflate_result => 1,
     handles => ['display_name'],
     reflect => [qw(id first_name last_name baz_list)],
    );

  reflect_actions
    (
     Create => { attrs =>[qw(first_name last_name baz_list)] },
     Update => { attrs =>[qw(first_name last_name baz_list)] },
     Delete => {},
     CustomAction => { attrs =>[qw(last_name baz_list)] },
    );
};

1;

package ComponentUI::TestModel;

use lib 't/lib';
use Reaction::InterfaceModel::DBIC::SchemaClass;

class TestModel, which {

  domain_model '_testdb_schema' =>
    (
     isa => 'RTest::TestDB',
     reflect => [
                 'Foo',
                 ['Bar' => 'ComponentUI::TestModel::Bars'],
                 ['Baz' => 'ComponentUI::TestModel::Baz', 'bazes' ],
                ],
    );
};

1;

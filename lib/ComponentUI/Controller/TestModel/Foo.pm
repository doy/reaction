package ComponentUI::Controller::TestModel::Foo;

use base 'Reaction::UI::Controller::Collection::CRUD';
use Reaction::Class;

__PACKAGE__->config(
  model_name => 'TestModel',
  collection_name => 'Foo',
  action => { base => { Chained => '/base', PathPart => 'testmodel/foo' } },
);

1;

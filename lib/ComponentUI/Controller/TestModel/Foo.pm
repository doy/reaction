package ComponentUI::Controller::TestModel::Foo;

use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestModel',
  model_name => 'Foo',
  action => { base => { Chained => '/base', PathPart => 'testmodel/foo' } },
);

1;

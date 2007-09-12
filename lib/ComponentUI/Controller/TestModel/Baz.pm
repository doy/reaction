package ComponentUI::Controller::TestModel::Baz;

use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestModel',
  model_name => 'Baz',
  action => { base => { Chained => '/base', PathPart => 'testmodel/baz' } },
);

1;

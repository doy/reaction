package ComponentUI::Controller::TestModel::Baz;

use base 'Reaction::UI::Controller::Collection::CRUD';
use Reaction::Class;

__PACKAGE__->config(
  model_name => 'TestModel',
  collection_name => 'Baz',
  action => { base => { Chained => '/base', PathPart => 'testmodel/baz' } },
);

1;

package ComponentUI::Controller::TestModel::Bar;

use base 'Reaction::UI::Controller::Collection::CRUD';
use Reaction::Class;

__PACKAGE__->config(
  model_name => 'TestModel',
  collection_name => 'Bar',
  action => {
    base => { Chained => '/base', PathPart => 'testmodel/bar' },
  },
);

1;

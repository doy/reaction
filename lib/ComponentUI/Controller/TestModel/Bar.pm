package ComponentUI::Controller::TestModel::Bar;

use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestModel',
  model_name => 'Bar',
  action => { base => { Chained => '/base', PathPart => 'testmodel/bar' },
              list => { ViewPort => { layout => 'bar_list' } },
              update => { ViewPort => { layout => 'bar_form' } },
              create => { ViewPort => { layout => 'bar_form' } } },
);

1;

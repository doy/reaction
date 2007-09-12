package ComponentUI::Controller::Bar;

use strict;
use warnings;
use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestDB',
  model_name => 'Bar',
  action => { base => { Chained => '/base', PathPart => 'bar' },
              list => { ViewPort => { layout => 'bar_list' } },
              update => { ViewPort => { layout => 'bar_form' } },
              create => { ViewPort => { layout => 'bar_form' } } },
);

1;

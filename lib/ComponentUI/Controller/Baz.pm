package ComponentUI::Controller::Baz;

use strict;
use warnings;
use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestDB',
  model_name => 'Baz',
  action => { base => { Chained => '/base', PathPart => 'baz' } },
);

1;

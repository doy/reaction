package ComponentUI::Controller::Foo;

use strict;
use warnings;
use base 'Reaction::UI::CRUDController';
use Reaction::Class;

__PACKAGE__->config(
  model_base => 'TestDB',
  model_name => 'Foo',
  action => { base => { Chained => '/base', PathPart => 'foo' } },
);

1;

use lib 't/lib';
use strict;
use warnings;

use Test::Class;
use RTest::UI::ViewPort::ListView;

Test::Class->runtests(
  RTest::UI::ViewPort::ListView->new,
);

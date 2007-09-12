use lib 't/lib';
use strict;
use warnings;

use Test::Class;
use RTest::UI::Window;

Test::Class->runtests(
  RTest::UI::Window->new,
);

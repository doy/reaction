use lib 't/lib';
use strict;
use warnings;

use Test::Class;
use Test::More;
use RTest::UI::Window;

TODO: { 
  local $TODO = 'sort this out later';
  Test::Class->runtests(
    RTest::UI::Window->new,
  );
};

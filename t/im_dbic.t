use lib 't/lib';
use strict;
use warnings;

use Test::Class;
use RTest::InterfaceModel::Reflector::DBIC;

Test::Class->runtests(
  RTest::InterfaceModel::Reflector::DBIC->new(),
);

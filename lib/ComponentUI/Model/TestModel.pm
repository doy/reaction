package ComponentUI::Model::TestModel;

use lib 't/lib';
use aliased 'Catalyst::Model::Reaction::InterfaceModel::DBIC';

use Reaction::Class;

class TestModel is DBIC, which {

};

__PACKAGE__->config
  (
   im_class => 'ComponentUI::TestModel',
   db_dsn   => 'dbi:SQLite:t/var/reaction_test_withdb.db',
  );

1;

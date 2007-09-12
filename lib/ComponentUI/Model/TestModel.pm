package ComponentUI::Model::TestModel;

use lib 't/lib';
use base 'Reaction::InterfaceModel::DBIC::ModelBase';

__PACKAGE__->config
  (
   im_class => 'ComponentUI::TestModel',
   db_dsn   => 'dbi:SQLite:t/var/reaction_test_withdb.db',
  );

1;

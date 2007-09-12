package ComponentUI::Model::Action;

use Reaction::Class;

use lib 't/lib';
use RTest::TestDB;

use aliased 'Reaction::InterfaceModel::Action::DBIC::ActionReflector';

my $r = ActionReflector->new;

$r->reflect_actions_for('RTest::TestDB::Foo' => __PACKAGE__);
$r->reflect_actions_for('RTest::TestDB::Bar' => __PACKAGE__);
$r->reflect_actions_for('RTest::TestDB::Baz' => __PACKAGE__);

1;

package ComponentUI::TestModel::Bars;

use lib 't/lib';
use Reaction::InterfaceModel::DBIC::ObjectClass;

class Bars, which{
  domain_model '_bars_store' =>
    (isa => 'RTest::TestDB::Bar', inflate_result => 1,
     reflect => [qw(name foo published_at avatar)],
    );

  reflect_actions
    (
     Create => { attrs =>[qw(name foo published_at avatar)] },
     Update => { attrs =>[qw(name foo published_at avatar)] },
     Delete => {},
    );

};

1;

package ComponentUI::TestModel::Foo::Action::CustomAction;

use Reaction::Class;

class CustomAction is 'Reaction::InterfaceModel::Action', which {
  has first_name => (isa => 'NonEmptySimpleStr', is => 'rw', lazy_build => 1);
};

1;

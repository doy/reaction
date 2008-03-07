package Reaction::InterfaceModel::Action::DBIC::Result;

use Reaction::InterfaceModel::Action;
use Reaction::Types::DBIC 'Row';
use Reaction::Class;

class Result is 'Reaction::InterfaceModel::Action', which {

  has '+target_model' => (isa => Row);

};

1;

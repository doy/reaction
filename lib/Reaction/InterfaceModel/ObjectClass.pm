package Reaction::InterfaceModel::ObjectClass;

use Reaction::ClassExporter;
use Reaction::Class;

use Reaction::InterfaceModel::Object;

class ObjectClass which {

  overrides default_base => sub { ('Reaction::InterfaceModel::Object') };

};

1;

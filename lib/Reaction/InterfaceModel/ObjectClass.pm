package Reaction::InterfaceModel::ObjectClass;

use Reaction::ClassExporter;
use Reaction::Class;

use Reaction::InterfaceModel::Object;

class ObjectClass which {

  overrides default_base => sub { ('Reaction::InterfaceModel::Object') };

  overrides exports_for_package => sub {
    my ($self, $package) = @_;
    return (super(),
            domain_model => sub {
              $package->meta->add_domain_model(@_);
            },
           );
  };
};

1;

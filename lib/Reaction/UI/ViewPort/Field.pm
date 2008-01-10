package Reaction::UI::ViewPort::Field;

use Reaction::Class;
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::Meta::InterfaceModel::Object::ParameterAttribute';

class Field is 'Reaction::UI::ViewPort', which {

  has value        => (is => 'rw', lazy_build => 1);
  has name         => (is => 'rw', isa => 'Str', lazy_build => 1);
  has label        => (is => 'rw', isa => 'Str', lazy_build => 1);
  has value_string => (is => 'rw', isa => 'Str', lazy_build => 1);

  has model     => (is => 'ro', isa => Object,             required => 1);
  has attribute => (is => 'ro', isa => ParameterAttribute, required => 1);

  implements adopt_value => as {};

  implements _build_name => as { shift->attribute->name };
  implements _build_value_string => as { shift->value };

  implements _build_label => as {
    join(' ', map { ucfirst } split('_', shift->name));
  };

  #unlazify and move it to build. to deal with array use typeconstraints and coercions
  implements _build_value => as {
    my ($self) = @_;
    my $reader = $self->attribute->get_read_method;
    my $predicate = $self->attribute->predicate;
    #this is bound to blow the fuck if !model->$predicate what to do?
    return $self->model->$reader if (!$predicate || $self->model->$predicate);
    return;
  };

};

1;

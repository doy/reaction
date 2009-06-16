package Reaction::InterfaceModel::Action::Role::SimpleMethodCall;

use Reaction::Role;
use Scalar::Util 'blessed';
requires '_target_model_method';

sub can_apply { 1; }

sub do_apply {
  my ($self) = @_;
  my $object = $self->target_model;
  my $method_name = $self->_target_model_method;
  if(my $method_ref = $object->can($method_name)){
    return $object->$method_ref();
  }
  confess("Object ".blessed($object)." doesn't support method ${method_name}");
}

1;

package Reaction::InterfaceModel::Action::Role::SimpleMethodCall;

use Reaction::Role;

requires '_target_model_method';

sub can_apply { 1; }

sub do_apply {
  my ($self) = @_;
  $self->target_model->${\$self->_target_model_method};
}

1;

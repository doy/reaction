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

  implements adopt_value => as {
    my ($self) = @_;
    $self->needs_sync(1) if $self->has_attribute;
  };

  implements value_string => as { shift->value };

  implements sync_to_action => as {
    my ($self) = @_;
    return unless $self->needs_sync && $self->has_attribute && $self->has_value;
    my $attr = $self->attribute;
    if (my $tc = $attr->type_constraint) {
      my $value = $self->value;
      if ($tc->has_coercion) {
        $value = $tc->coercion->coerce($value);
      }
      my $error = $tc->validate($self->value);
      if (defined $error) {
        $self->message($error);
        return;
      }
    }
    my $writer = $attr->get_write_method;
    confess "No writer for attribute" unless defined($writer);
    $self->action->$writer($self->value);
    $self->needs_sync(0);
  };

  implements sync_from_action => as {
    my ($self) = @_;
    return unless !$self->needs_sync && $self->has_attribute;
    $self->message($self->action->error_for($self->attribute)||'');
  };

  override accept_events => sub { ('value', super()) };

};

1;

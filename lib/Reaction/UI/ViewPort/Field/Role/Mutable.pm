package Reaction::UI::ViewPort::Field::Role::Mutable;

use Reaction::Role;

use aliased 'Reaction::InterfaceModel::Action';
use aliased 'Reaction::Meta::InterfaceModel::Action::ParameterAttribute';

role Mutable, which {
  has model     => (is => 'ro', isa => Action, required => 1);
  has attribute => (is => 'ro', isa => ParameterAttribute, required => 1);

  has value      => (is => 'rw', lazy_build => 1, trigger_adopt('value'));
  has needs_sync => (is => 'rw', isa => 'Int', default => 0);
  has message    => (is => 'rw', isa => 'Str');

  implements adopt_value => as {
    my ($self) = @_;
    $self->needs_sync(1); # if $self->has_attribute;
  };

  implements sync_to_action => as {
    my ($self) = @_;
    return unless $self->needs_sync && $self->has_value;
    my $attr = $self->attribute;
    if (my $tc = $attr->type_constraint) {
      my $value = $self->value;
      $value = $tc->coercion->coerce($value) if ($tc->has_coercion);
      my $error = $tc->validate($self->value); # should we be checking against $value?
      if (defined $error) {
        $self->message($error);
        return;
      }
    }
    my $writer = $attr->get_write_method;
    confess "No writer for attribute" unless defined($writer);
    $self->action->$writer($self->value); #should we be passing $value ?
    $self->needs_sync(0);
  };

  implements sync_from_action => as {
    my ($self) = @_;
    return unless !$self->needs_sync; # && $self->has_attribute;
    $self->message($self->action->error_for($self->attribute) || '');
  };

  around accept_events => sub { ('value', shift->(@_)) };

};

1;

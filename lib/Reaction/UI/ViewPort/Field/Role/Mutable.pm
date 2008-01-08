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
    my $value = $self->value;
    $self->model->$writer($self->value); #should we be passing $value ?
    $self->needs_sync(0);
  };

  implements sync_from_action => as {
    my ($self) = @_;
    return unless !$self->needs_sync; # && $self->has_attribute;
    $self->message($self->model->error_for($self->attribute) || '');
  };

  around accept_events => sub { ('value', shift->(@_)) };

};

1;

=head1 NAME

Reaction::UI::ViewPort::Role::Actions

=head1 DESCRIPTION

A role to ease attaching actions to L<Reaction::InterfaceModel::Object>s

=head1 ATTRIBUTES

=head2 needs_sync

=head2 message

=head2 model

=head2 attribute

=head2 value

=head1 METHODS

=head2 accept_events

=head2 sync_from_action

=head2 sync_to_action

=head2 adopt_value

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::ViewPort::Field::Role::Mutable;

use Reaction::Role;

use aliased 'Reaction::InterfaceModel::Action';
use aliased 'Reaction::Meta::InterfaceModel::Action::ParameterAttribute';

role Mutable, which {
  has model     => (is => 'ro', isa => Action, required => 1);
  has attribute => (is => 'ro', isa => ParameterAttribute, required => 1);

  has value      => (
    is => 'rw', lazy_build => 1, trigger_adopt('value'),
    clearer => 'clear_value',
  );
  has needs_sync => (is => 'rw', isa => 'Int', default => 0);
  #predicates are autmagically generated for lazy and non-required attrs
  has message => (is => 'rw', isa => 'Str', clearer => 'clear_message');

  after clear_value => sub {
    my $self = shift;
    $self->clear_message if $self->has_message;
    $self->needs_sync(1);
  };

  implements adopt_value => as {
    my ($self) = @_;
    $self->clear_message if $self->has_message;
    $self->needs_sync(1); # if $self->has_attribute;
  };

  implements can_sync_to_action => as {
    my $self = shift;
    return 1 unless $self->needs_sync;
    my $attr = $self->attribute;

    if ($self->has_value) {
      my $value = $self->value;
      if (my $tc = $attr->type_constraint) {
        $value = $tc->coercion->coerce($value) if ($tc->has_coercion);
        if (defined (my $error = $tc->validate($value))) {
          $self->message($error);
          return;
        }
      }
    } else {
      return if $attr->is_required;
    }
    return 1;
  };

  implements sync_to_action => as {
    my ($self) = @_;
    return unless $self->needs_sync;
    return unless $self->can_sync_to_action;

    my $attr = $self->attribute;

    if ($self->has_value) {
      my $value = $self->value;
      if (my $tc = $attr->type_constraint) {
        #this will go away when we have moose dbic. until then though...
        $value = $tc->coercion->coerce($value) if ($tc->has_coercion);
      }
      my $writer = $attr->get_write_method;
      confess "No writer for attribute" unless defined($writer);
      $self->model->$writer($value);
    } else {
      my $predicate = $attr->get_predicate_method;
      confess "No predicate for attribute" unless defined($predicate);
      if ($self->model->$predicate) {
        my $clearer = $attr->get_clearer_method;
        confess "${predicate} returned true but no clearer for attribute"
          unless defined($clearer);
        $self->model->$clearer;
      }
    }
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

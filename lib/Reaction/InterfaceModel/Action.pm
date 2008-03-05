package Reaction::InterfaceModel::Action;

use Reaction::Meta::InterfaceModel::Action::Class;
use metaclass 'Reaction::Meta::InterfaceModel::Action::Class';

use Reaction::Meta::Attribute;
use Reaction::Class;

class Action which {

  has target_model => (is => 'ro', required => 1,
                       metaclass => 'Reaction::Meta::Attribute');

  has ctx => (isa => 'Catalyst', is => 'ro', required => 1,
                metaclass => 'Reaction::Meta::Attribute');

  implements parameter_attributes => as {
    shift->meta->parameter_attributes;
  };

  implements parameter_hashref => as {
    my ($self) = @_;
    my %params;
    foreach my $attr ($self->parameter_attributes) {
      my $reader = $attr->get_read_method;
      my $predicate = $attr->get_predicate_method;
      next if defined($predicate) && !$self->$predicate;
      $params{$attr->name} = $self->$reader;
    }
    return \%params;
  };

  implements can_apply => as {
    my ($self) = @_;
    foreach my $attr ($self->parameter_attributes) {
      my $predicate = $attr->get_predicate_method;
      if ($self->attribute_is_required($attr)) {
        return 0 unless $self->$predicate;
      }
      if ($attr->has_valid_values) {
        unless ($predicate && !($self->$predicate)) {
          my $reader = $attr->get_read_method;
          return 0 unless $attr->check_valid_value($self, $self->$reader);
        }
      }
    }
    return 1;
  };

  implements error_for => as {
    my ($self, $attr) = @_;
    confess "No attribute passed to error_for" unless defined($attr);
    unless (ref($attr)) {
      my $meta = $self->meta->find_attribute_by_name($attr);
      confess "Can't find attribute ${attr} on $self" unless $meta;
      $attr = $meta;
    }
    return $self->error_for_attribute($attr);
  };

  implements error_for_attribute => as {
    my ($self, $attr) = @_;
    my $reader = $attr->get_read_method;
    my $predicate = $attr->get_predicate_method;
    if ($self->attribute_is_required($attr)) {
      unless ($self->$predicate) {
        return $attr->name." is required";
      }
    }
    if ($self->$predicate && $attr->has_valid_values) {
      unless ($attr->check_valid_value($self, $self->$reader)) {
        return "Not a valid value for ".$attr->name;
      }
    }
    return; # ok
  };

  implements attribute_is_required => as {
    my ($self, $attr) = @_;
    return $attr->is_required;
  };

  sub sync_all { }

};

1;

=head1 NAME

Reaction::InterfaceModel::Action

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 target_model

=head2 ctx

=head2 parameter_attributes

=head1 SEE ALSO

L<Reaction::Meta::Attribute>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

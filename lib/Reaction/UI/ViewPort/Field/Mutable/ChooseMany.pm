package Reaction::UI::ViewPort::Field::Mutable::ChooseMany;

use Reaction::Class;

my $listify = sub{
  return [] unless defined $_[0];
  return ref $_[0] eq 'ARRAY' ? $_[0] : [$_[0]];
};

class ChooseMany is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => 'ArrayRef');

  does 'Reaction::UI::ViewPort::Field::Role::Mutable';
  does 'Reaction::UI::ViewPort::Field::Role::Choices';

  around value => sub {
    my $orig = shift;
    my $self = shift;
    return $orig->($self) unless @_;
    my $value = $listify->(shift);
    $_ = $self->str_to_ident($_) for @$value;
    my $checked = $self->attribute->check_valid_value($self->action, $value);
    # i.e. fail if any of the values fail
    confess "Not a valid set of values"
      if (@$checked < @$value || grep { !defined($_) } @$checked);
    $orig->($self, $checked);
  };

  #XXX go away!
  override _build_value => sub {
    return super() || [];
  };

  implements is_current_value => as {
    my ($self, $check_value) = @_;
    my @our_values = @{$self->value||[]};
    $check_value = $self->obj_to_str($check_value) if ref($check_value);
    return grep { $self->obj_to_str($_) eq $check_value } @our_values;
  };

  implements current_value_choices => as {
    my $self = shift;
    my @all = grep { $self->is_current_value($_->{value}) } @{$self->value_choices};
    return [ @all ];
  };

  implements available_value_choices => as {
    my $self = shift;
    my @all = grep { !$self->is_current_value($_->{value}) } @{$self->value_choices};
    return [ @all ];
  };

  around handle_events => sub {
    my $orig = shift;
    my ($self, $events) = @_;
    my $ev_value = $listify->($events->{value});
    if (delete $events->{add_all_values}) {
      $events->{value} = [map {$self->obj_to_str($_)} @{$self->valid_values}];
    } elsif (exists $events->{add_values} && delete $events->{do_add_values}) {
      my $add = $listify->(delete $events->{add_values});
      $events->{value} = [ @{$ev_value}, @$add ];
    } elsif (delete $events->{remove_all_values}) {
      $events->{value} = [];
    }elsif (exists $events->{remove_values} && delete $events->{do_remove_values}) {
      my $remove = $listify->(delete $events->{remove_values});
      my %r = map { ($_ => 1) } @$remove;
      $events->{value} = [ grep { !$r{$_} } @{$ev_value} ];
    }
    return $orig->(@_);
  };

};

1;

=head1 NAME

Reaction::UI::ViewPort::Field::ChooseMany

=head1 DESCRIPTION

=head1 METHODS

=head2 is_current_value

=head2 current_values

=head2 available_values

=head2 available_value_names

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

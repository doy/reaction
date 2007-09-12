package Reaction::UI::ViewPort::Field::ChooseMany;

use Reaction::Class;

class ChooseMany is 'Reaction::UI::ViewPort::Field::ChooseOne', which {

  has '+layout' => (default => 'dual_select_group');
  
  has '+value' => (isa => 'ArrayRef');
  
  has available_value_names => 
      (isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  
  has value_names => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  
  my $listify = sub {                  # quick utility function, $listify->($arg)
    return (defined($_[0])
             ? (ref($_[0]) eq 'ARRAY'
                 ? $_[0]               # \@arr => \@arr
                 : [$_[0]])            # $scalar => [$scalar]
             : []);                    # undef => []
  };
  
  around value => sub {
    my $orig = shift;
    my $self = shift;
    if (@_) {
      my $value = $listify->(shift);
      if (defined $value) {
	$_ = $self->str_to_ident($_) for @$value;
        my $checked = $self->attribute->check_valid_value($self->action, $value);
        # i.e. fail if any of the values fail
	confess "Not a valid set of values" 
	  if (@$checked < @$value || grep { !defined($_) } @$checked);

        $value = $checked;
      }
      $orig->($self, $value);
    } else {
      $orig->($self);
    }
  };
  
  override build_value => sub {
    return super() || [];
  };
  
  implements is_current_value => as {
    my ($self, $check_value) = @_;
    my @our_values = @{$self->value||[]};
    #$check_value = $check_value->id if ref($check_value);
    #return grep { $_->id eq $check_value } @our_values;
    $check_value = $self->obj_to_str($check_value) if ref($check_value);
    return grep { $self->obj_to_str($_) eq $check_value } @our_values;
  };
  
  implements current_values => as {
    my $self = shift;
    my @all = grep { $self->is_current_value($_) } @{$self->valid_values};
    return [ @all ];
  };
  
  implements available_values => as {
    my $self = shift;
    my @all = grep { !$self->is_current_value($_) } @{$self->valid_values};
    return [ @all ];
  };
  
  implements build_available_value_names => as {
    my $self = shift;
    my @all = @{$self->available_values};
    my $meth = $self->value_map_method;
    my @names = map { $_->$meth } @all;
    return [ sort @names ];
  };
  
  implements build_value_names => as {
    my $self = shift;
    my @all = @{$self->value||[]};
    my $meth = $self->value_map_method;
    my @names = map { $_->$meth } @all;
    return [ sort @names ];
  };
  
  around handle_events => sub {
    my $orig = shift;
    my ($self, $events) = @_;
    my $ev_value = $listify->($events->{value});
    if (delete $events->{add_all_values}) {
      $events->{value} = $self->valid_values;
    } 
    if (delete $events->{do_add_values} && exists $events->{add_values}) {
      my $add = $listify->(delete $events->{add_values});
      $events->{value} = [ @{$ev_value}, @$add ];
    }
    if (delete $events->{remove_all_values}) {
      $events->{value} = [];
    } 
    if (delete $events->{do_remove_values} && exists $events->{remove_values}) {
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

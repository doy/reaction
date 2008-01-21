package Reaction::UI::ViewPort;

use Reaction::Class;
use Scalar::Util qw/blessed/;

class ViewPort which {

  has location => (isa => 'Str', is => 'rw', required => 1);
  has layout => (isa => 'Str', is => 'rw', lazy_build => 1);
  has outer => (isa => 'Reaction::UI::ViewPort', is => 'rw', weak_ref => 1);
  has inner => (isa => 'Reaction::UI::ViewPort', is => 'rw');
  has focus_stack => (
    isa => 'Reaction::UI::FocusStack', is => 'rw', weak_ref => 1
  );
  has _tangent_stacks => (
    isa => 'HashRef', is => 'ro', default => sub { {} }
  );
  has ctx => (isa => 'Catalyst', is => 'ro', required => 1);

  implements _build_layout => as {
    '';
  };

  implements create_tangent => as {
    my ($self, $name) = @_;
    my $t_map = $self->_tangent_stacks;
    if (exists $t_map->{$name}) {
      confess "Can't create tangent with already existing name ${name}";
    }
    my $loc = join('.', $self->location, $name);
    my $tangent = Reaction::UI::FocusStack->new(loc_prefix => $loc);
    $t_map->{$name} = $tangent;
    return $tangent;
  };

  implements focus_tangent => as {
    my ($self, $name) = @_;
    if (my $tangent = $self->_tangent_stacks->{$name}) {
      return $tangent;
    } else {
      return;
    }
  };

  implements focus_tangents => as {
    return keys %{shift->_tangent_stacks};
  };

  implements child_event_sinks => as {
    my $self = shift;
    return values %{$self->_tangent_stacks};
  };

  implements apply_events => as {
    my ($self, $ctx, $events) = @_;
    return unless keys %$events;
    $self->apply_child_events($ctx, $events);
    $self->apply_our_events($ctx, $events);
  };

  implements apply_child_events => as {
    my ($self, $ctx, $events) = @_;
    return unless keys %$events;
    foreach my $child ($self->child_event_sinks) {
      confess blessed($child) ."($child) is not a valid object"
        unless blessed($child) && $child->can('apply_events');
      $child->apply_events($ctx, $events);
    }
  };

  implements apply_our_events => as {
    my ($self, $ctx, $events) = @_;
    my @keys = keys %$events;
    return unless @keys;
    my $loc = $self->location;
    my %our_events;
    foreach my $key (keys %$events) {
      if ($key =~ m/^${loc}:(.*)$/) {
        $our_events{$1} = $events->{$key};
      }
    }
    if (keys %our_events) {
      #warn "$self: events ".join(', ', %our_events)."\n";
      $self->handle_events(\%our_events);
    }
  };

  implements handle_events => as {
    my ($self, $events) = @_;
    foreach my $event ($self->accept_events) {
      if (exists $events->{$event}) {
        #my $name = eval{$self->name};
        #$self->ctx->log->debug("Applying Event: $event on $name with value: ". $events->{$event});
        $self->$event($events->{$event});
      }
    }
  };

  implements accept_events => as { () };

  implements event_id_for => as {
    my ($self, $name) = @_;
    return join(':', $self->location, $name);
  };

  implements sort_by_spec => as {
    my ($self, $spec, $items) = @_;
    return $items if not defined $spec;

    my @order;
    if (ref $spec eq 'ARRAY') {
      @order = @$spec;
    }
    elsif (not ref $spec) {
      return $items unless length $spec;
      @order = split /\s+/, $spec;
    }

    my %order_map = map {$_ => 0} @$items;
    for my $order_num (0..$#order) {
      $order_map{ $order[$order_num] } = ($#order - $order_num) + 1;
    }

    return [sort {$order_map{$b} <=> $order_map{$a}} @$items];
  };

};

1;


=head1 NAME

Reaction::UI::ViewPort - Page layout building block

=head1 SYNOPSIS

  # Create a new ViewPort:
  # $stack isa Reaction::UI::FocusStack object
  my $vp = $stack->push_viewport('Reaction::UI::ViewPort', layout => 'xthml');

  # Fetch ViewPort higher up the stack (further out)
  my $outer = $vp->outer();

  # Fetch ViewPort lower down (further in)
  my $inner = $vp->inner();

  # Create a named tangent stack for this ViewPort
  my $substack = $vp->create_tangent('name');

  # Retrieve a tangent stack for this ViewPort
  my $substack = $vp->forcus_tangent('name');

  # Get the names of all the tangent stacks for this ViewPort
  my @names = $vp->focus_tangents();

  # Fetch all the tangent stacks for this ViewPort
  # This is called by apply_events
  my $stacks = $vp->child_event_sinks();


  ### The following methods are all called automatically when using
  ### Reaction::UI::Controller(s)
  # Resolve current events with this ViewPort
  $vp->apply_events($ctx, $param_hash);

  # Apply current events to all tangent stacks
  # This is called by apply_events
  $vp->apply_child_events($ctx, $params_hash);

  # Apply current events to this ViewPort
  # This is called by apply_events
  $vp->apply_our_events($ctx, $params_hash);

=head1 DESCRIPTION

A ViewPort describes part of a page, it can be a field, a form or
an entire page. ViewPorts are created on a
L<Reaction::UI::FocusStack>, usually belonging to a controller or
another ViewPort. Each ViewPort knows it's own position in the stack
it is in, as well as the stack containing it.

Each ViewPort has a specific location in the heirarchy of viewports
making up a page. The hierarchy is determined as follows: The first
ViewPort in a stack is labeled C<0>, the second is C<1> and so on. If
a ViewPort is in a named tangent, it's location will contain the name
of the tangent in it's location.

For example, the first ViewPort in the 'left' tangent of the main
ViewPort has location C<0.left.0>.

Several ViewPort attributes are set by
L<Reaction::UI::FocusStack/push_viewport> when new ViewPorts are
created, these are as follows:

=over

=item Automatic:

=over

=item outer

The outer attribute is set to the previous ViewPort in the stack when
creating a ViewPort, if the ViewPort is the first in the stack, it
will be undef.

=item inner

The inner attribute is set to the next ViewPort down in the stack when
it is created, if this is the last ViewPort in the stack, it will be
undef.

=item focus_stack

The focus_stack attribute is set to the L<Reaction::UI::FocusStack>
object that created the ViewPort.

=item ctx

The ctx attribute will be passed automatically when using
L<Reaction::UI::Controller/push_viewport> to create a ViewPort in the
base stack of a controller. When creating tangent stacks, you may have
to pass it in yourself.

=back

=item Optional:

=over

=item location

=item layout

The layout attribute can either be specifically passed when calling
C<push_viewport>, or it will be determined using the last part of the
ViewPorts classname.

=item column_order

This is generally used by more specialised ViewPorts such as the
L<ListView|Reaction::UI::ViewPort::ListView> or
L<ActionForm|Reaction::UI::ViewPort::ActionForm>. It can be either a
space separated list of column names, or an arrayref of column names.

=back

=back

=head1 METHODS

=head2 outer

=over

=item Arguments: none

=back

Fetch the ViewPort outside this one in the page hierarchy.

=head2 inner

=over

=item Arguments: none

=back

Fetch the ViewPort inside this one in the page hierarchy.

=head2 create_tangent

=over

=item Arguments: $tangent_name

=back

Create a new named L<Reaction::UI::FocusStack> inside this
ViewPort. The created FocusStack is returned.

=head2 focus_tangent

=over

=item Arguments: $tangent_name

=back

Fetch a named FocusStack from this ViewPort.

=head2 focus_tangents

=over

=item Arguments: none

=back

Returns a list of names of all the known tangents in this ViewPort.

=head2 focus_stack

Return the L<Reaction::UI::FocusStack> object that this ViewPort is in.

=head2 apply_events

=over

=item Arguments: $ctx, $params_hashref

=back

This method is called by the FocusStack object to resolve all events
for the ViewPort.

=head2 apply_child_events

=over

=item Arguments: $ctx, $params_hashref

=back

Resolve the given events for all the tangents of this ViewPort. Called
by L<apply_events>.

=head2 apply_our_events

=over

=item Arguments: $ctx, $events

=back

Resolve the given events that match the location of this
ViewPort. Called by L<apply_events>.

=head2 handle_events

=over

=item Arguments: $events

=back

Actually call the event handlers for this ViewPort. Called by
L<apply_our_events>. By default this will do nothing, subclass
ViewPort and implement L<accept_events>.

=head2 accept_events

=over

=item Arguments: none

=back

Implement this method in a subclass and return a list of events that
your ViewPort is accepting.

=head2 event_id_for

=over

=item Arguments: $name

=back

Create an id for the given event name and this ViewPort. Generally
returns the location and the name, joined with a colon.

=head2 sort_by_spec

=over

=item Arguments: $spec, $items

=back

Sorts the given list of items such that the ones that also appear in
the spec are at the beginning. This is called by
L<Reaction::UI::ViewPort::ActionForm> and
L<Reaction::UI::ViewPort::ListView>, and gets passed L<column_order>
as the spec argument.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

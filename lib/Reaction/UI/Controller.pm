package Reaction::UI::Controller;

use base qw(
  Catalyst::Controller
  Catalyst::Component::ACCEPT_CONTEXT
  Reaction::Object
);

use Reaction::Class;

sub push_viewport {
  my $self = shift;
  my $c = $self->context;
  my $focus_stack = $c->stash->{focus_stack};
  my ($class, @proto_args) = @_;
  my %args;
  if (my $vp_attr = $c->stack->[-1]->attributes->{ViewPort}) {
    if (ref($vp_attr) eq 'ARRAY') {
      $vp_attr = $vp_attr->[0];
    }
    if (ref($vp_attr) eq 'HASH') {
      if (my $conf_class = delete $vp_attr->{class}) {
        $class = $conf_class;
      }
      %args = %{ $self->merge_config_hashes($vp_attr, {@proto_args}) };
    } else {
      $class = $vp_attr;
      %args = @proto_args;
    }
  } else {
    %args = @proto_args;
  }

  $args{ctx} = $c;

  if (exists $args{next_action} && !ref($args{next_action})) {
    $args{next_action} = [ $self, 'redirect_to', $args{next_action} ];
  }
  $focus_stack->push_viewport($class, %args);
}

sub pop_viewport {
  return shift->context->stash->{focus_stack}->pop_viewport;
}

sub pop_viewports_to {
  my ($self, $vp) = @_;
  return $self->context->stash->{focus_stack}->pop_viewports_to($vp);
}

sub redirect_to {
  my ($self, $c, $to, $cap, $args, $attrs) = @_;

  #the confess calls could be changed later to $c->log ?
  my $action;
  if(!ref $to){
      $action = $self->action_for($to);
      confess("Failed to locate action ${to} in " . blessed($self)) unless $action;
  }
  elsif( blessed $to && $to->isa('Catalyst::Action') ){
      $action = $to;
  } elsif(ref $action eq 'ARRAY' && @$action == 2){ #is that overkill / too strict?
      $action = $c->controller($to->[0])->action_for($to->[1]);
      confess("Failed to locate action $to->[1] in $to->[0]" ) unless $action;
  } else{
      confess("Failed to locate action from ${to}");
  }

  $cap ||= $c->req->captures;
  $args ||= $c->req->args;
  $attrs ||= {};
  my $uri = $c->uri_for($action, $cap, @$args, $attrs);
  $c->res->redirect($uri);
}

1;

__END__;

=head1 NAME

Reaction::UI::Controller

=head1 DESCRIPTION

Base Reaction Controller class. Inherits from:

=over 4

=item L<Catalyst::Controller>
=item L<Catalyst::Component::ACCEPT_CONTEXT>
=item L<Reaction::Object>

=back

=head1 METHODS

=head2 push_viewport $vp_class, %args

Will create a new instance of $vp_class with the arguments of %args
merged in with any arguments in the ViewPort attribute of the current
Catalyst action (also accessible through the controller config), add
it to the main FocusStack (C<$c-E<gt>stash-E<gt>{focus_stack}>) and
return the instantiated viewport.

TODO: explain how next_action as a scalar gets converted to the redirect arrayref thing

=head2 pop_viewport

=head2 pop_viewport_to $vp

Shortcut to subs of the same name in the main FocusStack (C<$c-E<gt>stash-E<gt>{focus_stack}>)

=head2 redirect_to $c, $to, $captures, $args, $attrs

If C<$to> is a string then redirects to the action of the same name  in the current
 controller (C<$c-E<gt>controller> not C<$self>).

If C<$to> isa L<Catalyst::Action>
it will pass the argument directly to C<$c-E<gt>uri_for>.

If C<$to> is an ArrayRef with two items it will treat the first as a Controller name
and the second as the action name whithin that controller.

C<$captures>, C<$args>, and C<$attrs> are equivalent to the same arguments in
C<uri_for>. If left blank the current request captures and args will be used
and C<$attrs> will be passed as an empty HashRef.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

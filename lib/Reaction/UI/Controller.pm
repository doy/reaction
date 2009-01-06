package Reaction::UI::Controller;

use base qw(Catalyst::Controller Reaction::Object);

use Reaction::Class;
use Scalar::Util 'weaken';
use namespace::clean -except => [ qw(meta) ];

has context => (is => 'ro', isa => 'Object', weak_ref => 1);
with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
  my ($self, $c, @args) = @_;
  my $newself =  $self->new($self->_application, {%$self, context => $c, @args});
  return $newself;
}

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
  my $reftype = ref($to);
  if( $reftype eq '' ){
    $action = $self->action_for($to);
    confess("Failed to locate action ${to} in " . blessed($self)) unless $action;
  } elsif($reftype eq 'ARRAY' && @$to == 2){ #is that overkill / too strict?
    $action = $c->controller($to->[0])->action_for($to->[1]);
    confess("Failed to locate action $to->[1] in $to->[0]" ) unless $action;
  } elsif( blessed $to && $to->isa('Catalyst::Action') ){
    $action = $to;
  } else{
    confess("Failed to locate action from ${to}");
  }

  $cap ||= $c->req->captures;
  $args ||= $c->req->args;
  $attrs ||= {};
  my $uri = $c->uri_for($action, $cap, @$args, $attrs);
  $c->res->redirect($uri);
}

sub make_context_closure {
  my($self, $closure) = @_;
  my $ctx = $self->context;
  weaken($ctx);
  return sub { $closure->($ctx, @_) };
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

Creates a new instance of the L<Reaction::UI::ViewPort> class
($vp_class) using the rest of the arguments given (%args). Defaults of
the action can be overridden by using the C<ViewPort> key in the
controller configuration. For example to override the default number
of items in a CRUD list action:

__PACKAGE__->config(
                    action => { 
                        list => { ViewPort => { per_page => 50 } },
    }
  );

The ViewPort is added to the L<Reaction::UI::Window>'s FocusStack in
the stash, and also returned to the calling code.

Related items:

=over

=item L<Reaction::UI::Controller::Root>
=item L<Reaction::UI::Window>

=back

TODO: explain how next_action as a scalar gets converted to the redirect arrayref thing

=head2 pop_viewport

=head2 pop_viewport_to $vp

Call L<Reaction::UI::FocusStack/pop_viewport> or
L<Reaction::UI::FocusStack/pop_viewport_to> on 
the C<< $c->stash->{focus_stack} >>.

=head2 redirect_to $c, $to, $captures, $args, $attrs

Construct a URI and redirect to it.

$to can be:

=over

=item The name of an action in the current controller.

=item A L<Catalyst::Action> instance.

=item An arrayref of controller name and the name of an action in that
controller.

=back

$captures and $args default to the current requests $captures and
$args if not supplied.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

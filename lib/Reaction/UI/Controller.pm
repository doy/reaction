package Reaction::UI::Controller;

use base qw/Catalyst::Controller::BindLex Reaction::Object/;
use Reaction::Class;

sub push_viewport {
  my $self = shift;
  my $focus_stack :Stashed;
  my ($class, @proto_args) = @_;
  my %args;
  my $c = Catalyst::Controller::BindLex::_get_c_obj(4);
  if (my $vp_attr = $c->stack->[-1]->attributes->{ViewPort}) {
    if (ref($vp_attr) eq 'ARRAY') {
      $vp_attr = $vp_attr->[0];
    }
    if (ref($vp_attr) eq 'HASH') {
      if (my $conf_class = delete $vp_attr->{class}) {
        $class = $conf_class;
      }
      %args = (%$vp_attr, @proto_args);
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
  my $focus_stack :Stashed;
  return $focus_stack->pop_viewport;
}

sub pop_viewports_to {
  my ($self, $vp) = @_;
  my $focus_stack :Stashed;
  return $focus_stack->pop_viewports_to($vp);
}

sub redirect_to {
  my ($self, $c, $to, $cap, $args, $attrs) = @_;

  #the confess calls could be changed later to $c->log ?
  my $action;
  if(!ref $to){
      $action = $self->action_for($to);
      confess("Failed to locate action ${to} in " . $self->blessed) unless $action;
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

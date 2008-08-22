package Reaction::UI::ViewPort::Action::Role::Apply;

use Reaction::Role;
use MooseX::Types::Moose qw/Str CodeRef/;

requires 'do_apply';
has apply_label => (is => 'rw', isa => Str, lazy_build => 1);
has on_apply_callback => (is => 'rw', isa => CodeRef);

sub _build_apply_label { 'apply' }

sub can_apply { 1 }

sub apply {
  my $self = shift;
  if ($self->can_apply && (my $result = $self->do_apply)) {
    $self->on_apply_callback->($self => $result) if $self->has_on_apply_callback;
    return 1;
  } else {
    if( my $coderef = $self->can('close_label') ){
      $self->$coderef( $self->close_label_cancel );
    }
    return 0;
  }
};

around accept_events => sub { ( 'apply', shift->(@_) ) };

1;

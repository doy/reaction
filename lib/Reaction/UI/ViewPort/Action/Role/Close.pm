package Reaction::UI::ViewPort::Action::Role::Close;

use Reaction::Role;
use MooseX::Types::Moose qw/Str CodeRef/;
with 'Reaction::UI::ViewPort::Action::Role::Apply';

has close_label => (is => 'rw', isa => Str, lazy_build => 1);
has on_close_callback => (is => 'rw', isa => CodeRef);
has close_label_close => (is => 'rw', isa => Str, lazy_build => 1);
has close_label_cancel => (is => 'rw', isa => Str, lazy_build => 1);

sub _build_close_label { shift->_build_close_label_close }
sub _build_close_label_close { 'close' }
sub _build_close_label_cancel { 'cancel' }

sub can_close { 1 }

sub close {
  my $self = shift;
  return unless $self->has_on_close_callback;
  $self->on_close_callback->($self);
}

around apply => sub {
  my $orig = shift;
  my $self = shift;
  my $success = $self->$orig(@_);
  $self->close_label( $self->close_label_cancel ) unless $success;
  return $success;
};

# can't do a close-type operation if there's nowhere to go afterwards
around accept_events => sub {
  my $orig = shift;
  my $self = shift;
  ( ($self->has_on_close_callback ? ('close') : ()), $self->$orig(@_) );
};

1;

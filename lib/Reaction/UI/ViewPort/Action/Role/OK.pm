package Reaction::UI::ViewPort::Action::Role::OK;

use Reaction::Role;
use MooseX::Types::Moose qw/Str/;
with 'Reaction::UI::ViewPort::Action::Role::Close';

has ok_label => (is => 'rw', isa => 'Str', lazy_build => 1);

sub _build_ok_label { 'ok' }

sub ok {
  my $self = shift;
  $self->close(@_) if $self->apply(@_);
}

around accept_events => sub {
  my $orig = shift;
  my $self = shift;
  ( ($self->has_on_close_callback ? ('ok') : ()), $self->$orig(@_) );
};

1;

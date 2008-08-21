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

__END__

=head1 NAME

Reaction::UI::ViewPort::Action::Role::Close

=head1 ATTRIBUTES

=head2 ok_label

Default: 'ok'

=head1 METHODS

=head2 ok

Calls C<apply>, and then C<close> if successful.

=head1 SEE ALSO

L<Reaction::UI::ViewPort::Action::Role::Apply>

L<Reaction::UI::ViewPort::Action::Role::Close>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

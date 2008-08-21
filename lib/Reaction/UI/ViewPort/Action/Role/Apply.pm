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

__END__

=head1 NAME

Reaction::UI::ViewPort::Action::Role::Apply

=head1 ATTRIBUTES

=head2 apply_label

Default: 'apply'

=head2 on_apply_callback

CodeRef.

=head1 METHODS

=head2 can_apply

=head2 apply

Calls a user-supplied C<do_apply> and if it is successful runs the
C<on_apply_callback> passing C<$self> and the result of C<do_apply> as args.

=head1 SEE ALSO

L<Reaction::UI::ViewPort::Action::Role::Close>

L<Reaction::UI::ViewPort::Action::Role::OK>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


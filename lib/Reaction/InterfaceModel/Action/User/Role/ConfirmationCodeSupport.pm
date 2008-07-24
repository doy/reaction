package Reaction::InterfaceModel::Action::User::Role::ConfirmationCodeSupport;

use Reaction::Role;
use Digest::MD5;

use namespace::clean -except => [ qw(meta) ];


#requires qw/target_model ctx/;
sub generate_confirmation_code {
  my $self = shift;
  my $ident = $self->target_model->identity_string.
    $self->target_model->password;
  my $secret = $self->ctx->config->{confirmation_code_secret};
  die "Application config does not define confirmation_code_secret"
    unless $secret;
  return Digest::MD5::md5_hex($secret.$ident);
};



1;

=head1 NAME

Reaction::InterfaceModel::Action::User::Role::ConfirmationCodeSupport

=head1 DESCRIPTION

=head2 generate_confirmation_code

=head2 meta

Need to define confirmation_code_secret in application config.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

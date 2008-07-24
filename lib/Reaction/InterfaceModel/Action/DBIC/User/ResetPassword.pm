package Reaction::InterfaceModel::Action::DBIC::User::ResetPassword;

use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::InterfaceModel::Action::User::ResetPassword';

with 'Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword';

__PACKAGE__->meta->make_immutable;


1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::ResetPassword

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::InterfaceModel::Action::DBIC::User::ChangePassword;

use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::InterfaceModel::Action::User::ChangePassword';

with 'Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword';

__PACKAGE__->meta->make_immutable;


1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::ChangePassword

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

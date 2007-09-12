package Reaction::InterfaceModel::Action::DBIC::User::ResetPassword;

use Reaction::Class;

class ResetPassword
  is 'Reaction::InterfaceModel::Action::User::ResetPassword',
  which {

    does 'Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword';

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::ResetPassword

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

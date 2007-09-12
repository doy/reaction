package Reaction::InterfaceModel::Action::DBIC::User::ChangePassword;

use Reaction::Class;

class ChangePassword
  is 'Reaction::InterfaceModel::Action::User::ChangePassword',
  which {

  does 'Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword';

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::ChangePassword

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

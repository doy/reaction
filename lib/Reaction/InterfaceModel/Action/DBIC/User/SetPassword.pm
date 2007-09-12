package Reaction::InterfaceModel::Action::DBIC::User::SetPassword;

use Reaction::Class;

class SetPassword
  is 'Reaction::InterfaceModel::Action::User::SetPassword',
  which {

  does 'Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword';

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::SetPassword

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

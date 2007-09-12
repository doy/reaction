package Reaction::InterfaceModel::Action::DBIC::User::Role::SetPassword;

use Reaction::Role;

role SetPassword, which {

  #requires qw/target_model/;

  implements do_apply => as {
    my $self = shift;
    my $user = $self->target_model;
    $user->password($self->new_password);
    $user->update;
    return $user;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::User::Role::ChangePassword

=head1 DESCRIPTION

=head2 meta

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

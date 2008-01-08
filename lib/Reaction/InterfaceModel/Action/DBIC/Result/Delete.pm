package Reaction::InterfaceModel::Action::DBIC::Result::Delete;

use Reaction::Types::DBIC 'Row';
use Reaction::Class;

class Delete is 'Reaction::InterfaceModel::Action', which {
  has '+target_model' => (isa => 'Row');

  sub can_apply { 1 }

  implements do_apply => as {
    my $self = shift;
    return $self->target_model->delete;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::Result::Delete

=head1 DESCRIPTION

=head2 target_model

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

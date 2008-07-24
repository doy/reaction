package Reaction::InterfaceModel::Action::DBIC::ResultSet::DeleteAll;

use Reaction::Types::DBIC 'ResultSet';
use Reaction::Class;
use Reaction::InterfaceModel::Action;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::InterfaceModel::Action';



has '+target_model' => (isa => ResultSet);

sub can_apply { 1 }
sub do_apply {
  my $self = shift;
  return $self->target_model->delete_all;
};

__PACKAGE__->meta->make_immutable;


1;


=head1 NAME

Reaction::InterfaceModel::Action::DBIC::ResultSet::DeleteAll

=head1 DESCRIPTION

Deletes every item in the target_model ResultSet

=head2 target_model

=head2 error_for_attribute

=head2 sync_all

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

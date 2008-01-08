package Reaction::InterfaceModel::Action::DBIC::Result::Update;

use Reaction::InterfaceModel::Action;
use Reaction::Types::DBIC 'Row';
use Reaction::Class;

class Update is 'Reaction::InterfaceModel::Action', which {

  does 'Reaction::InterfaceModel::Action::DBIC::Role::CheckUniques';

  has '+target_model' => (isa => 'Row');

  implements BUILD => as {
    my ($self) = @_;
    my $tm = $self->target_model;
    foreach my $attr ($self->parameter_attributes) {
      my $writer = $attr->get_write_method;
      my $name = $attr->name;
      my $tm_attr = $tm->meta->find_attribute_by_name($name);
      next unless ref $tm_attr;
      my $tm_reader = $tm_attr->get_read_method;
      $self->$writer($tm->$tm_reader);
    }
  };

  implements do_apply => as {
    my $self = shift;
    my $args = $self->parameter_hashref;
    my $model = $self->target_model;
    foreach my $name (keys %$args) {
      my $tm_attr = $model->meta->find_attribute_by_name($name);
      next unless ref $tm_attr;
      my $tm_writer = $tm_attr->get_write_method;
      $model->$tm_writer($args->{$name});
    }
    $model->update;
    return $model;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::Result::Update

=head1 DESCRIPTION

=head2 target_model

=head2 error_for_attribute

=head2 sync_all

=head2 BUILD

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::InterfaceModel::Action::DBIC::ResultSet::Create;

use Reaction::Types::DBIC 'ResultSet';
use Reaction::Class;
use Reaction::InterfaceModel::Action;
use Reaction::InterfaceModel::Action::DBIC::Role::CheckUniques;

class Create is 'Reaction::InterfaceModel::Action', which {

  does 'Reaction::InterfaceModel::Action::DBIC::Role::CheckUniques';

  has '+target_model' => (isa => ResultSet);

  implements do_apply => as {
    my $self = shift;
    my $args = $self->parameter_hashref;
    my $new = $self->target_model->new({});
    my @delay;
    foreach my $name (keys %$args) {
      my $tm_attr = $new->meta->find_attribute_by_name($name);
      unless ($tm_attr) {
        warn "Unable to find attr for ${name}";
        next;
      }
      my $tm_writer = $tm_attr->get_write_method;
      unless ($tm_writer) {
        warn "Unable to find writer for ${name}";
        next;
      }
      if ($tm_attr->type_constraint->name eq 'ArrayRef'
          || $tm_attr->type_constraint->is_subtype_of('ArrayRef')) {
        push(@delay, [ $tm_writer, $args->{$name} ]);
      } else {
        $new->$tm_writer($args->{$name});
      }
    }
    $new->insert;
    foreach my $d (@delay) {
      my ($meth, $val) = @$d;
      $new->$meth($val);
    }
    return $new;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::ResultSet::Create

=head1 DESCRIPTION

=head2 target_model

=head2 error_for_attribute

=head2 sync_all

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::ViewPort::Collection::Grid;

use Reaction::Class;

use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::Collection::Grid::Member';

class Grid is 'Reaction::UI::ViewPort::Collection', which {

  has field_order     => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has excluded_fields => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has field_labels    => ( is => 'ro', isa => 'HashRef',  lazy_build => 1);

  has computed_field_order => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  ####################################
  implements _build_member_class => as { Member };

  implements _build_field_labels => as {
    my $self = shift;
    my %labels;
    for my $field ( @{$self->computed_field_order}){
      $labels{$field} = join(' ', map{ ucfirst } split('_', $field));
    }
    return \%labels;
  };

  implements _build_field_order     => as { []; };
  implements _build_excluded_fields => as { []; };

  implements _build_computed_field_order => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef } @{ $self->excluded_fields };
    #treat _$field_name as private and exclude fields with no reader
    my @names = grep { $_ !~ /^_/ && !exists($excluded{$_})} map { $_->name }
      grep {
        !($_->has_type_constraint &&
          ($_->type_constraint->is_a_type_of('ArrayRef') ||
           eval {$_->type_constraint->name->isa('Reaction::InterfaceModel::Collection')} ||
           eval { $_->_isa_metadata->isa('Reaction::InterfaceModel::Collection') }
          )
         )  }
        grep { defined $_->get_read_method }
          $self->current_collection->member_type->parameter_attributes;

    return $self->sort_by_spec($self->field_order, \@names);
  };

  before _build_members => sub {
    my ($self) = @_;
    $self->member_args->{computed_field_order} ||= $self->computed_field_order;
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::ViewPort::Collection

=head1 DESCRIPTION

This subclass of L<Reaction::UI::ViewPort::Collection> allows you to display a
homogenous collection of Reaction::InterfaceModel::Objects as a grid.

=head1 ATTRIBUTES

=head2 field_order

=head2 excluded_fields

=head2 field_labels

=head2 computed_field_order

=head1

=head1 INTERNAL METHODS

These methods, although stable, are subject to change without notice. These are meant
to be used only by developers. End users should refrain from using these methods to
avoid potential breakages.

=head1 SEE ALSO

L<Reaction::UI::ViewPort::Collection>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

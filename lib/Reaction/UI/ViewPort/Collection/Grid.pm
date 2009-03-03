package Reaction::UI::ViewPort::Collection::Grid;

use Reaction::Class;

use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::Collection::Grid::Member::WithActions';

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort::Collection';

has field_order => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has excluded_fields => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has included_fields => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has computed_field_order => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has _raw_field_labels => (
  is => 'rw',
  isa => 'HashRef',
  init_arg => 'field_labels',
  default => sub { {} },
);

has field_labels => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
  init_arg => undef,
);

has member_action_count => (
  is => 'rw',
  isa => 'Int',
  required => 1,
  lazy => 1,
  default => sub {
    my $self = shift;
    for (@{ $self->members }) {
      my $protos = $_->action_prototypes;
      return scalar(keys(%$protos));
    }
    return 1;
  },
);

####################################
sub _build_member_class { WithActions };

sub _build_field_labels {
  my $self = shift;
  my %labels = %{$self->_raw_field_labels};
  for my $field ( @{$self->computed_field_order}) {
    next if defined $labels{$field};
    $labels{$field} = join(' ', map{ ucfirst } split('_', $field));
  }
  return \%labels;
}

sub _build_field_order { []; }

sub _build_excluded_fields { []; }

sub _build_included_fields { [] }

#this is a total clusterfuck and it sucks we should just eliminate it and have
# the grid members not render ArrayRef or Collection fields
sub _build_computed_field_order {
  my ($self) = @_;
  my %excluded = map { $_ => undef } @{ $self->excluded_fields };
  my %included = map { $_ => undef } @{ $self->included_fields };
  #treat _$field_name as private and exclude fields with no reader
  my @names = grep { $_ !~ /^_/ &&  (!%included || exists( $included{$_}) )
    && !exists($excluded{$_})} map { $_->name }
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
}

around _build_members => sub {
  my $orig = shift;
  my $self = shift;
  $self->member_args->{computed_field_order} ||= $self->computed_field_order;
  $self->member_args->{computed_action_order} ||= [];
  my $members = $self->$orig(@_);

  # cache everything yo
  for my $member (@$members){
    $member->clear_computed_action_order;
    my $order = $member->computed_action_order;
    @{ $self->member_args->{computed_action_order} } = @$order;
    last;
  }

  return $members;
};

__PACKAGE__->meta->make_immutable;


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

List of field names to exclude.

=head2 included_fields

List of field names to include. If both C<included_fields> and
C<excluded_fields> are specified the result is those fields which
are in C<included_fields> and not in C<excluded_fields>.

=head2 included_fields

List of field names to include. If both C<included_fields> and
C<excluded_fields> are specified the result is those fields which
are in C<included_fields> and not in C<excluded_fields>.


=head2 field_labels

=head2 _raw_field_labels

=head2 computed_field_order

=head2 member_action_count

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

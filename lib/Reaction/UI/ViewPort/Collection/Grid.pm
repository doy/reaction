package Reaction::UI::ViewPort::Collection::Grid;

use Reaction::Class;

use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::Collection::Grid::Member';

class Grid is 'Reaction::UI::ViewPort::Collection', which {

  has field_order    => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has field_labels   => ( isa => 'HashRef',  is => 'ro', lazy_build => 1);

  has ordered_fields  => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has excluded_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  ####################################
  implements _build_member_class => as { };

  implements _build_field_labels => as {
    my $self = shift;
    my %labels;
    for my $field ( @{$self->field_order}){
      $labels{$field} = join(' ', map{ ucfirst } split('_', $field));
    }
    return \%labels;
  };

  implements _build_ordered_fields => as {
    my ($self) = @_;
    confess("current_collection lacks a value for 'member_type' attribute")
      unless $self->current_collection->has_member_type;
    my %excluded = map { $_ => undef } @{ $self->excluded_fields };
    #treat _$field_name as private and exclude fields with no reader
    my @names = grep { $_ !~ /^_/ && !exists($exclude{$_})} map { $_->name }
      grep { defined $_->get_read_method }
        $self->current_collection->member_type->meta->parameter_attributes;
    return $self->sort_by_spec($self->field_order, \@names);
  };

  before _build_members => sub {
    my ($self) = @_;
    $self->member_args->{ordered_fields} ||= $self->ordered_fields;
  };

};



1;

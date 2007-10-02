package Reaction::UI::ViewPort::GridView;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::GridView::Row';
use aliased 'Reaction::InterfaceModel::Collection';

class GridView is 'Reaction::UI::ViewPort', which {

  has exclude_columns => ( isa => 'ArrayRef', is => 'ro' );
  has column_names    => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has rows            => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has row_args        => ( isa => 'HashRef',  is => 'ro');

  has collection         => (isa => Collection, is => 'ro', required   => 1);
  has current_collection => (isa => Collection, is => 'rw', lazy_build => 1);

  implements build_rows => as{
    my $self = shift;

    my (@rows, $i);
    for my $object ( $self->current_collection->members ){
      my $row = Row->new
        (
         ctx            => $self->ctx,
         object         => $object,
         location       => join('-', $self->location, 'row', ++$i),
         column_order   => $self->column_order, #XXX clean from ViewPort
         exclude_fields => $self->exclude_columns || [],
         $self->has_row_args ? %{ $self->row_args } : (),

        );
      push(@rows, $row);
    }
    return \@rows;
  };

  implements build_column_names => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef }
      @{ $self->has_exclude_columns ? $self->exclude_columns : [] };
    #XXX this abuse of '_im_class' needs to be fixed ASAP
    my $object_class = $self->collection->_im_class;
    my @fields = $object_class->meta->compute_all_applicable_attributes;
    #eliminate excluded fields & treat names that start with an underscore as private
    @fields = grep {$_->name !~ /^_/ && !exists $excluded{$_->name} } @fields;
    #eliminate fields marked as collections, or fields that are arrayrefs
    @fields = grep {
      !($_->has_type_constraint &&
        ($_->type_constraint->is_a_type_of('ArrayRef') ||
         eval {$_->type_constraint->name->isa('Reaction::InterfaceModel::Collection')} ||
         eval { $_->_isa_metadata->isa('Reaction::InterfaceModel::Collection') }
        )
       )  } @fields;

    #order the columns all nice and pretty, and only get fields with readers, duh
    return $self->sort_by_spec
      ( $self->column_order, [ map { (($_->get_read_method) || ()) } @fields] );
  };

  implements build_current_collection => as {
    shift->collection;
  };

};



1;

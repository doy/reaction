package Reaction::UI::ViewPort::GridView;

use Reaction::Class;

use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::GridView::Entity';

class GridView is 'Reaction::UI::ViewPort', which {

  has exclude_fields => ( isa => 'ArrayRef', is => 'ro' );
  has field_order    => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has field_labels   => ( isa => 'HashRef',  is => 'ro', lazy_build => 1);


  has entities       => ( isa => 'ArrayRef', is => 'rw', lazy_build => 1);

  has collection         => (isa => IM_Collection, is => 'ro', required   => 1);
  has current_collection => (isa => IM_Collection, is => 'rw', lazy_build => 1);

  has entity_class => ( isa => 'Str', is => 'rw', lazy_build => 1);
  has entity_args  => ( is => 'rw' );

  implements BUILD => as {
    my ($self, $args) = @_;
    my $entity_args = delete $args->{Entity};
    $self->entity_args( $entity_args ) if ref $entity_args;
  };

  after clear_current_collection => sub{
    shift->clear_entities; #clear the entitiesis the current collection changes, duh
  };

  implements build_entity_class => as { Entity };

  implements build_field_order => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef }
      @{ $self->has_exclude_fields ? $self->exclude_fields : [] };
    #XXX this abuse of '_im_class' needs to be fixed ASAP
    my $object_class = $self->collection->_im_class;
    my @fields = $object_class->meta->parameter_attributes;
    #obviously only get fields with readers.
    @fields = grep { $_->get_read_method } @fields;
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
    my $ordered = $self->sort_by_spec
      ( $self->column_order, [ map { (($_->name) || ()) } @fields] );

    return $ordered;
  };

  implements build_current_collection => as {
    shift->collection;
  };

  implements build_field_labels => as {
    my $self = shift;
    my %labels;
    for my $field ( @{$self->field_order}){
      $labels{$field} = join(' ', map{ ucfirst } split('_', $field));
    }
    return \%labels;
  };

  implements build_entities => as {
    my ($self) = @_;
    my (@entities, $i);
    my $args = $self->has_entity_args ? $self->entity_args : {};
    my $builders = {};
    my $ctx = $self->ctx;
    my $loc = $self->location;
    my $order = $self->field_order;
    my $class = $self->entity_class;
    for my $obj ( $self->current_collection->members ) {
      my $row = $class->new(
                            ctx           => $ctx,
                            object        => $obj,
                            location      => join('-', $loc, 'row', $i++),
                            field_order   => $order,
                            builder_cache => $builders,
                            ref $args ? %$args : ()
                           );
      push(@entities, $row);
    }
    return \@entities;
  };

};



1;

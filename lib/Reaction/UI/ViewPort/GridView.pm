package Reaction::UI::ViewPort::GridView;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::DisplayField::Text';
use aliased 'Reaction::UI::ViewPort::DisplayField::Number';
use aliased 'Reaction::UI::ViewPort::DisplayField::Boolean';
use aliased 'Reaction::UI::ViewPort::DisplayField::String';
use aliased 'Reaction::UI::ViewPort::DisplayField::DateTime';
use aliased 'Reaction::UI::ViewPort::DisplayField::RelatedObject';

use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';

class GridView is 'Reaction::UI::ViewPort', which {

  has exclude_columns => ( isa => 'ArrayRef', is => 'ro' );
  has column_names    => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has rows            => ( isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has row_args        => ( isa => 'HashRef',  is => 'ro');

  has collection         => (isa => IM_Collection, is => 'ro', required   => 1);
  has current_collection => (isa => IM_Collection, is => 'rw', lazy_build => 1);

  has ordered_columns => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  implements build_ordered_columns => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef }
      @{ $self->has_exclude_columns ? $self->exclude_columns : [] };
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

  implements build_column_names => as {
    my $self = shift;
    [ map{ join(' ', map{ ucfirst } split('_', $_)) } @{$self->ordered_columns} ];
  }

    implements build_rows => as {
      my ($self) = @_;
      my @columns = @{ $self->ordered_columns };

      my (@rows, $i);
      my $builders = {};
      for my $obj ( $self->current_collection->members ) {
        $i++;
        my @cells;
        for my $col (@columns) {
          my $attr = $obj->meta->find_attribute_by_name($col);
          my $build_meth = $builders->{$col} ||= $self->build_fields_for($attr);
          my $loc =  join('-', $self->location, 'row', $i, 'field', $attr->name);
          my $args = {Field => { $attr->name => {location => $loc} } };
          my $cell = $self->$build_meth($obj, $attr, $args);
          push(@cells, $cell) if $cell;
        }
        push(@rows,\@cells)
      }

      return \@rows;
    };

  implements build_fields_for => as {
    my ($self, $attr) = @_;
    my $attr_name = $attr->name;
    my $builder = "build_fields_for_name_${attr_name}";
    return $builder if $self->can($builder);
    if ($attr->has_type_constraint) {
      my $constraint = $attr->type_constraint;
      my $base_name = $constraint->name;
      my $tried_isa = 0;
    CONSTRAINT: while (defined($constraint)) {
        my $name = $constraint->name;
        $name = $attr->_isa_metadata if($name eq '__ANON__');
        if (eval { $name->can('meta') } && !$tried_isa++) {
          foreach my $class ($name->meta->class_precedence_list) {
            my $mangled_name = $class;
            $mangled_name =~ s/:+/_/g;
            my $builder = "build_fields_for_type_${mangled_name}";
            return $builder if $self->can($builder);
          }
        }
        if (defined($name)) {
          unless (defined($base_name)) {
            $base_name = "(anon subtype of ${name})";
          }
          my $mangled_name = $name;
          $mangled_name =~ s/:+/_/g;
          my $builder = "build_fields_for_type_${mangled_name}";
          return $builder if $self->can($builder);
        }
        $constraint = $constraint->parent;
      }
      if (!defined($constraint)) {
        confess "Can't build field ${attr_name} of type ${base_name} without $builder method or build_fields_for_type_<type> method for type or any supertype";
      }
    } else {
      confess "Can't build field ${attr} without $builder method or type constraint";
    }
  };


  implements build_simple_field => as {
    my ($self, $class, $obj, $attr, $args) = @_;
    my $attr_name = $attr->name;
    my %extra;
    if (my $config = $args->{Field}{$attr_name}) {
      %extra = %$config;
    }

    return $class->new(
                       object => $obj,
                       attribute => $attr,
                       name => $attr->name,
                       ctx => $self->ctx,
                       %extra
                      );
  };

  implements build_fields_for_type_Num => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/number'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(Number, $obj, $attr, $args);
  };

  implements build_fields_for_type_Int => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/number'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(Number, $obj, $attr, $args);
  };

  implements build_fields_for_type_Bool => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/boolean'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(Boolean, $obj, $attr, $args);
  };

  implements build_fields_for_type_Password => as { return };

  implements build_fields_for_type_Str => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(String, $obj, $attr, $args);
  };

  implements build_fields_for_type_SimpleStr => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(String, $obj, $attr, $args);
  };

  implements build_fields_for_type_DateTime => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/date_time'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(DateTime, $obj, $attr, $args);
  };

  implements build_fields_for_type_Enum => as {
    my ($self, $obj, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    return $self->build_simple_field(String, $obj, $attr, $args);
  };

};



1;

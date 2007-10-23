package Reaction::UI::ViewPort::GridView::Entity;

use Reaction::Class;
use Catalyst::Utils;
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::UI::ViewPort::DisplayField::Text';
use aliased 'Reaction::UI::ViewPort::DisplayField::Number';
use aliased 'Reaction::UI::ViewPort::DisplayField::Boolean';
use aliased 'Reaction::UI::ViewPort::DisplayField::String';
use aliased 'Reaction::UI::ViewPort::DisplayField::DateTime';
use aliased 'Reaction::UI::ViewPort::DisplayField::RelatedObject';


class Entity is 'Reaction::UI::ViewPort', which {

  has object        => (isa => Object,     is => 'ro', required => 1);
  has field_order   => (isa => 'ArrayRef', is => 'ro', required => 1);

  has fields        => (isa => 'ArrayRef', is => 'rw', lazy_build => 1);
  has builder_cache => (isa => 'HashRef',  is => 'ro');
  has field_args   => (isa => 'rw');

  implements BUILD => as {
    my ($self, $args) = @_;
    my $field_args = delete $args->{Field};
    $self->field_args( {Field => $field_args} ) if ref $field_args;
  };

  implements build_fields => as {
    my ($self) = @_;
    my $obj      = $self->object;
    my $args     = $self->has_field_args    ? $self->field_args    : {};
    my $builders = $self->has_builder_cache ? $self->builder_cache : {};
    my @cells;
    for my $field (@{ $self->field_order }) {
      my $attr = $obj->meta->find_attribute_by_name($field);
      my $build_meth = $builders->{$field} ||= $self->get_builder_for($attr);
      my $loc = join('-', $self->location, 'field', $attr->name);
      my $vp_args = {Field => { $attr->name => {location => $loc} } };
      my $merged  = Catalyst::Utils::merge_hashes($args, $vp_args);
      my $cell = $self->$build_meth($obj, $attr, $merged);
      #XXX add a blank VP if !$cell here to mantain grid integrity
      push(@cells, $cell) if $cell;
    }
    return \@cells;
  };

  implements get_builder_for => as {
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

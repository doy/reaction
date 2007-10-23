package Reaction::UI::ViewPort::ObjectView;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::DisplayField::Text';
use aliased 'Reaction::UI::ViewPort::DisplayField::Number';
use aliased 'Reaction::UI::ViewPort::DisplayField::Boolean';
use aliased 'Reaction::UI::ViewPort::DisplayField::String';
use aliased 'Reaction::UI::ViewPort::DisplayField::DateTime';
use aliased 'Reaction::UI::ViewPort::DisplayField::RelatedObject';
use aliased 'Reaction::UI::ViewPort::DisplayField::List';
use aliased 'Reaction::UI::ViewPort::DisplayField::Collection';

class ObjectView is 'Reaction::UI::ViewPort', which {
  has object => (
    isa => 'Reaction::InterfaceModel::Object', is => 'ro', required => 1
  );

  has _field_map => (
    isa => 'HashRef', is => 'rw', init_arg => 'fields', lazy_build => 1,
  );

  has exclude_fields =>
      ( is => 'rw', isa => 'ArrayRef', required => 1, default => sub{ [] } );

  has ordered_fields => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);

  implements fields => as { shift->_field_map };

  implements BUILD => as {
    my ($self, $args) = @_;
    unless ($self->_has_field_map) {
      my @field_map;
      my $object = $self->object;
      my %excluded = map{$_ => 1} @{$self->exclude_fields};
      for my $attr (grep { !$excluded{$_->name} } $object->parameter_attributes) {
        push(@field_map, $self->build_fields_for($attr => $args));
      }

      my %field_map = @field_map;
      $self->_field_map( \%field_map );
    }
  };

  implements build_fields_for => as {
    my ($self, $attr, $args) = @_;
    my $attr_name = $attr->name;
    my $builder = "build_fields_for_name_${attr_name}";
    my @fields;
    if ($self->can($builder)) {
      @fields = $self->$builder($attr, $args); # re-use coderef from can()
    } elsif ($attr->has_type_constraint) {
      my $constraint = $attr->type_constraint;
      my $base_name = $constraint->name;
      my $tried_isa = 0;
      CONSTRAINT: while (defined($constraint)) {
        my $name = $constraint->name;
        if (eval { $name->can('meta') } && !$tried_isa++) {
          foreach my $class ($name->meta->class_precedence_list) {
            my $mangled_name = $class;
            $mangled_name =~ s/:+/_/g;
            my $builder = "build_fields_for_type_${mangled_name}";
            if ($self->can($builder)) {
              @fields = $self->$builder($attr, $args);
              last CONSTRAINT;
            }
          }
        }
        if (defined($name)) {
          unless (defined($base_name)) {
            $base_name = "(anon subtype of ${name})";
          }
          my $mangled_name = $name;
          $mangled_name =~ s/:+/_/g;
          my $builder = "build_fields_for_type_${mangled_name}";
          if ($self->can($builder)) {
            @fields = $self->$builder($attr, $args);
            last CONSTRAINT;
          }
        }
        $constraint = $constraint->parent;
      }
      if (!defined($constraint)) {
        confess "Can't build field ${attr_name} of type ${base_name} without $builder method or build_fields_for_type_<type> method for type or any supertype";
      }
    } else {
      confess "Can't build field ${attr} without $builder method or type constraint";
    }
    return @fields;
  };

  implements _build_field_map => as {
    confess "Lazy field map building not supported by default";
  };

  implements build_ordered_fields => as {
    my $self = shift;
    my $ordered = $self->sort_by_spec($self->column_order, [keys %{$self->_field_map}]);
    return [@{$self->_field_map}{@$ordered}];
  };

  implements build_simple_field => as {
    my ($self, $class, $attr, $args) = @_;
    my $attr_name = $attr->name;
    my %extra;
    if (my $config = $args->{Field}{$attr_name}) {
      %extra = %$config;
    }
    my $field = $class->new(
                  object => $self->object,
                  attribute => $attr,
                  name => $attr->name,
                  location => join('-', $self->location, 'field', $attr->name),
                  ctx => $self->ctx,
                  %extra
                );
    return ($attr_name => $field);
  };

  implements build_fields_for_type_Num => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(Number, $attr, $args);
  };

  implements build_fields_for_type_Int => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(Number, $attr, $args);
  };

  implements build_fields_for_type_Bool => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(Boolean, $attr, $args);
  };

  implements build_fields_for_type_Password => as { return };

  implements build_fields_for_type_Str => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(String, $attr, $args);
  };

  implements build_fields_for_type_SimpleStr => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(String, $attr, $args);
  };

  implements build_fields_for_type_DateTime => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(DateTime, $attr, $args);
  };

  implements build_fields_for_type_Enum => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(String, $attr, $args);
  };

  implements build_fields_for_type_ArrayRef => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(List, $attr, $args)
  };

  implements build_fields_for_type_Reaction_InterfaceModel_Collection => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(Collection, $attr, $args)
  };

  implements build_fields_for_type_Reaction_InterfaceModel_Object => as {
    my ($self, $attr, $args) = @_;
    return $self->build_simple_field(RelatedObject, $attr, $args);
  };

  no Moose;

  no strict 'refs';
  delete ${__PACKAGE__ . '::'}{inner};

};

1;

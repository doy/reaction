package Reaction::UI::ViewPort::Object;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Field::Text';
use aliased 'Reaction::UI::ViewPort::Field::Number';
use aliased 'Reaction::UI::ViewPort::Field::Integer';
use aliased 'Reaction::UI::ViewPort::Field::Boolean';
use aliased 'Reaction::UI::ViewPort::Field::String';
use aliased 'Reaction::UI::ViewPort::Field::DateTime';
use aliased 'Reaction::UI::ViewPort::Field::RelatedObject';
use aliased 'Reaction::UI::ViewPort::Field::List';
use aliased 'Reaction::UI::ViewPort::Field::Collection';

use aliased 'Reaction::InterfaceModel::Object' => 'IM_Object';

class Object is 'Reaction::UI::ViewPort', which {

  #everything is read only right now. Later I can make somethings read-write
  #but first I need to figure out what depends on what so we can have decent triggers
  has model  => (is => 'ro', isa => IM_Object, required => 1);
  has fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  has field_args    => (is => 'ro');
  has field_order   => (is => 'ro', isa => 'ArrayRef');

  has builder_cache   => (is => 'ro', isa => 'HashRef',  lazy_build => 1);
  has ordered_fields  => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has excluded_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  implements BUILD => as {
    my ($self, $args) = @_;
    my $field_args = delete $args->{Field};
    $self->field_args( $field_args ) if ref $field_args;
  };

  implements _build_excluded_fields => as { [] };
  implements _build_builder_cache   => as { {} };

  implements _build_fields => as {
    my ($self) = @_;
    my $obj  = $self->model;
    my $args = $self->has_field_args ? $self->field_args : {};
    my @fields;
    for my $field_name (@{ $self->field_order }) {
      my $attr = $obj->meta->find_attribute_by_name($field_name);
      my $meth = $self->builder_cache->{$field_name} ||= $self->get_builder_for($attr);
      my $field = $self->$meth($obj, $attr, ($args->{$field_name} || {}));
      push(@fields, $field) if $field;
    }
    return \@field;
  };

  implements _build_ordered_fields => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef } @{ $self->excluded_fields };
    #treat _$field_name as private and exclude fields with no reader
    my @names = grep { $_ !~ /^_/ && !exists($exclude{$_})} map { $_->name }
      grep { defined $_->get_read_method } $self->model->meta->parameter_attributes;
    return $self->sort_by_spec($self->field_order, \@names);
  };

  override child_event_sinks => sub {
    return ( shift->fields, super());
  };

  #candidate for shared role!
  implements get_builder_for => as {
    my ($self, $attr) = @_;
    my $attr_name = $attr->name;
    my $builder = "_build_fields_for_name_${attr_name}";
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
            my $builder = "_build_fields_for_type_${mangled_name}";
            return $builder if $self->can($builder);
          }
        }
        if (defined($name)) {
          unless (defined($base_name)) {
            $base_name = "(anon subtype of ${name})";
          }
          my $mangled_name = $name;
          $mangled_name =~ s/:+/_/g;
          my $builder = "_build_fields_for_type_${mangled_name}";
          return $builder if $self->can($builder);
        }
        $constraint = $constraint->parent;
      }
      if (!defined($constraint)) {
        confess "Can't build field ${attr_name} of type ${base_name} without $builder method or _build_fields_for_type_<type> method for type or any supertype";
      }
    } else {
      confess "Can't build field ${attr} without $builder method or type constraint";
    }
  };

  implements _build_simple_field => as {
    my ($self, %args) = @_;
    my $class = delete $args{class};
    confess("Can not build simple field without a viewport class")
      unless $class;
    confess("Can not build simple field without attribute")
      unless defined $args{attribute};

    my $field_name = $args{attribute}->name;
    return $class->new(
                       ctx       => $self->ctx,
                       model     => $self->model,
                       location  => join('-', $self->location, 'field', $field_name),
                       %args
                      );
  };

  implements _build_fields_for_type_Num => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Number, %$args);
  };

  implements _build_fields_for_type_Int => as {
    my ($self, $attr, $args) = @_;
    #XXX
    $self->_build_simple_field(attribute => $attr, class => Integer, %$args);
  };

  implements _build_fields_for_type_Bool => as {
    my ($self,  $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Boolean, %$args);
  };

  #XXX
  implements _build_fields_for_type_Password => as { return };

  implements _build_fields_for_type_Str => as {
    my ($self, $attr, $args) = @_;
    #XXX
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  implements _build_fields_for_type_SimpleStr => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  implements _build_fields_for_type_DateTime => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
  };

  implements _build_fields_for_type_Enum => as {
    my ($self, $attr, $args) = @_;
    #XXX
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  implements _build_fields_for_type_ArrayRef => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => List, %$args);
  };

  implements _build_fields_for_type_Reaction_InterfaceModel_Object => as {
    my ($self, $attr, $args) = @_;
    #XXX
    $self->_build_simple_field(attribute => $attr, class => RelatedObject, %$args);
  };

  implements _build_fields_for_type_Reaction_InterfaceModel_Collection => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Collection, %$args);
  };

};

1;

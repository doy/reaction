package Reaction::UI::ViewPort::Object;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Field::Text';
use aliased 'Reaction::UI::ViewPort::Field::Number';
use aliased 'Reaction::UI::ViewPort::Field::Integer';
use aliased 'Reaction::UI::ViewPort::Field::Boolean';
use aliased 'Reaction::UI::ViewPort::Field::String';
use aliased 'Reaction::UI::ViewPort::Field::DateTime';
use aliased 'Reaction::UI::ViewPort::Field::RelatedObject';
use aliased 'Reaction::UI::ViewPort::Field::Array';
use aliased 'Reaction::UI::ViewPort::Field::Collection';
use aliased 'Reaction::UI::ViewPort::Field::File';

use aliased 'Reaction::InterfaceModel::Object' => 'IM_Object';

class Object is 'Reaction::UI::ViewPort', which {

  #everything is read only right now. Later I can make somethings read-write
  #but first I need to figure out what depends on what so we can have decent triggers
  has model  => (is => 'ro', isa => IM_Object, required => 1);
  has fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

  has field_args    => (is => 'rw');
  has field_order   => (is => 'ro', isa => 'ArrayRef');

  has builder_cache   => (is => 'ro', isa => 'HashRef',  lazy_build => 1);
  has excluded_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has computed_field_order => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

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
    for my $field_name (@{ $self->computed_field_order }) {
      my $attr = $obj->meta->find_attribute_by_name($field_name);
      my $meth = $self->builder_cache->{$field_name} ||= $self->get_builder_for($attr);
      my $field = $self->$meth($attr, ($args->{$field_name} || {}));
      push(@fields, $field) if $field;
    }
    return \@fields;
  };

  implements _build_computed_field_order => as {
    my ($self) = @_;
    my %excluded = map { $_ => undef } @{ $self->excluded_fields };
    #treat _$field_name as private and exclude fields with no reader
    my @names = grep { $_ !~ /^_/ && !exists($excluded{$_})} map { $_->name }
      grep { defined $_->get_read_method } $self->model->meta->parameter_attributes;
    return $self->sort_by_spec($self->field_order || [], \@names);
  };

  override child_event_sinks => sub {
    return ( @{shift->fields}, super());
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
      my @tried;
    CONSTRAINT: while (defined($constraint)) {
        my $name = $constraint->name;
        $name = $attr->_isa_metadata if($name eq '__ANON__');
        if (eval { $name->can('meta') } && !$tried_isa++) {
          foreach my $class ($name->meta->class_precedence_list) {
            push(@tried, $class);
            my $mangled_name = $class;
            $mangled_name =~ s/:+/_/g;
            my $builder = "_build_fields_for_type_${mangled_name}";
            return $builder if $self->can($builder);
          }
        }
        if (defined($name)) {
          push(@tried, $name);
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
        confess "Can't build field ${attr_name} of type ${base_name} without "
                ."$builder method or _build_fields_for_type_<type> method "
                ."for type or any supertype (tried ".join(', ', @tried).")";
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
  implements _build_fields_for_type_Reaction_Types_Core_Password => as { return };

  implements _build_fields_for_type_Str => as {
    my ($self, $attr, $args) = @_;
    #XXX
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  implements _build_fields_for_type_Reaction_Types_Core_SimpleStr => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  implements _build_fields_for_type_Reaction_Types_DateTime_DateTimeObject => as {
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
    $self->_build_simple_field(attribute => $attr, class => Array, %$args);
  };

  implements _build_fields_for_type_File => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => File, %$args);
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

__END__;

=head1 NAME

Reaction::UI::ViewPort::Object

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 model

=head2 fields

=head2 field_args

=head2 field_order

=head2 builder_cache

=head2 excluded_fields

=head2 computed_field_order

=head1 INTERNAL METHODS

These methods, although stable, are subject to change without notice. These are meant
to be used only by developers. End users should refrain from using these methods to
avoid potential breakages.

=head2 BUILD

=head2 get_builder_for

=head2 _build_simple_field

=head2 _build_fields_for_type_Num

=head2 _build_fields_for_type_Int

=head2 _build_fields_for_type_Bool

=head2 _build_fields_for_type_Password

=head2 _build_fields_for_type_Str

=head2 _build_fields_for_type_SimpleStr

=head2 _build_fields_for_type_DateTime

=head2 _build_fields_for_type_Enum

=head2 _build_fields_for_type_ArrayRef

=head2 _build_fields_for_type_Reaction_InterfaceModel_Object

=head2 _build_fields_for_type_Reaction_InterfaceModel_Collection

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

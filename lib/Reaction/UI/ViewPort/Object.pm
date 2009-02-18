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
use aliased 'Reaction::UI::ViewPort::Field::Container';

use aliased 'Reaction::InterfaceModel::Object' => 'IM_Object';

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort';

#everything is read only right now. Later I can make somethings read-write
#but first I need to figure out what depends on what so we can have decent triggers
has model  => (is => 'ro', isa => IM_Object, required => 1);
has fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has field_args    => (is => 'rw');
has field_order   => (is => 'ro', isa => 'ArrayRef');

has builder_cache   => (is => 'ro', isa => 'HashRef',  lazy_build => 1);
has excluded_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has included_fields => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has computed_field_order => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);

has containers => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1);
has container_layouts => ( is => 'rw', isa => 'ArrayRef' );

sub BUILD {
  my ($self, $args) = @_;
  if( my $field_args = delete $args->{Field} ){
    $self->field_args( $field_args );
  }
}

sub _build_builder_cache { {} }
sub _build_excluded_fields { [] }
sub _build_included_fields { [] }

sub _build_containers {
  my $self = shift;

  my @container_layouts;
  if( $self->has_container_layouts ){
    #make sure we don't accidentally modify the original
    @container_layouts = map { {%$_} }@{ $self->container_layouts };
  } #we should always have a '_' container;
  unless (grep {$_->{name} eq '_'} @container_layouts ){
    unshift(@container_layouts, {name => '_'});
  }

  my %fields;
  my $ordered_field_names = $self->computed_field_order;
  @fields{ @$ordered_field_names } = @{ $self->fields };

  my %containers;
  my @container_order;
  for my $layout ( @container_layouts ){
    my @container_fields;
    my $name = $layout->{name};
    push(@container_order, $name);
    if( my $field_names = delete $layout->{fields} ){
      map{ push(@container_fields, $_) } grep { defined }
        map { delete $fields{$_} } @$field_names;
    }
    $containers{$name} = Container->new(
      ctx => $self->ctx,
      location => join( '-', $self->location, 'container', $name ),
      fields => \@container_fields,
      %$layout,
    );
  }
  if( keys %fields ){
    my @leftovers = grep { exists $fields{$_} } @$ordered_field_names;
    push(@{ $containers{_}->fields }, @fields{@leftovers} );
  }

  #only return containers with at least one field
  return [ grep { scalar(@{ $_->fields }) } @containers{@container_order} ];
}

sub _build_fields {
  my ($self) = @_;
  my $obj  = $self->model;
  my $args = $self->has_field_args ? $self->field_args : {};
  my @fields;
  my %param_attrs = map { $_->name => $_ } $obj->parameter_attributes;
  for my $field_name (@{ $self->computed_field_order }) {
    my $attr = $param_attrs{$field_name};
    my $meth = $self->builder_cache->{$field_name} ||= $self->get_builder_for($attr);
    my $field = $self->$meth($attr, ($args->{$field_name} || {}));
    next unless $field;
    push(@fields, $field);
  }
  return \@fields;
}

sub _build_computed_field_order {
  my ($self) = @_;
  my %excluded = map { $_ => undef } @{ $self->excluded_fields };
  my %included = map { $_ => undef } @{ $self->included_fields };
  #treat _$field_name as private and exclude fields with no reader
  my @names = grep { $_ !~ /^_/ && (!%included || exists( $included{$_}) )
    && !exists($excluded{$_}) } map { $_->name }
    grep { defined $_->get_read_method } $self->model->parameter_attributes;
  return $self->sort_by_spec($self->field_order || [], \@names);
}

override child_event_sinks => sub {
  return ( @{shift->fields}, super());
};

#candidate for shared role!
sub get_builder_for {
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
}

sub _build_simple_field {
  my ($self, %args) = @_;
  my $class = delete $args{class};
  confess("Can not build simple field without a viewport class")
    unless $class;
  confess("Can not build simple field without attribute")
    unless defined $args{attribute};

  my $field_name = $args{attribute}->name;
  return $class->new(
    ctx => $self->ctx,
    model => $self->model,
    location => join('-', $self->location, 'field', $field_name),
    %args
  );
}

sub _build_fields_for_type_Num {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Number, %$args);
}

sub _build_fields_for_type_Int {
  my ($self, $attr, $args) = @_;
  #XXX
  $self->_build_simple_field(attribute => $attr, class => Integer, %$args);
}

sub _build_fields_for_type_Bool {
  my ($self,  $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Boolean, %$args);
}

#XXX
sub _build_fields_for_type_Reaction_Types_Core_Password { return };

sub _build_fields_for_type_Str {
  my ($self, $attr, $args) = @_;
  #XXX
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_Reaction_Types_Core_SimpleStr {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_Reaction_Types_DateTime_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

sub _build_fields_for_type_Enum {
  my ($self, $attr, $args) = @_;
  #XXX
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_ArrayRef {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Array, %$args);
}

sub _build_fields_for_type_Reaction_Types_File_File {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => File, %$args);
}

sub _build_fields_for_type_Reaction_InterfaceModel_Object {
  my ($self, $attr, $args) = @_;
  #XXX
  $self->_build_simple_field(attribute => $attr, class => RelatedObject, %$args);
}

sub _build_fields_for_type_Reaction_InterfaceModel_Collection {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => Collection, %$args);
}

sub _build_fields_for_type_MooseX_Types_Common_String_SimpleStr {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => String, %$args);
}

sub _build_fields_for_type_MooseX_Types_Common_String_Password {
  return;
}

sub _build_fields_for_type_MooseX_Types_DateTime_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

sub _build_fields_for_type_DateTime {
  my ($self, $attr, $args) = @_;
  $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
}

__PACKAGE__->meta->make_immutable;

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

List of field names to exclude.

=head2 included_fields

List of field names to include. If both C<included_fields> and
C<excluded_fields> are specified the result is those fields which
are in C<included_fields> and not in C<excluded_fields>.

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

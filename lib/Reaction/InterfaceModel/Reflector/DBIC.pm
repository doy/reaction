package Reaction::InterfaceModel::Reflector::DBIC;

use aliased 'Reaction::InterfaceModel::Action::DBIC::ResultSet::Create';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Update';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Delete';

use aliased 'Reaction::InterfaceModel::Collection::Virtual::ResultSet';
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::InterfaceModel::Action';
use Reaction::Class;
use Class::MOP;

class DBIC, which {

  has model_class => (isa => "Str",  is => 'ro', required => 1);
  has debug_mode  =>
    (isa => 'Bool', is => 'rw', required => 1, default => '0');
  has make_classes_immutable =>
    (isa => 'Bool', is => 'rw', required => 1, default => '0');

  has default_object_actions =>
    ( isa => "ArrayRef", is => "rw", required => 1,
      default => sub{
        [ { name => 'Update', base => Update },
          { name => 'Delete', base => Delete,
            attributes => [],
          },
        ];
      } );

  has default_collection_actions =>
    ( isa => "ArrayRef", is => "rw", required => 1,
      default => sub{
        [{name => 'Create', base => Create}],
      } );

  implements BUILD => as{
    my $self = shift;
    my $ok = eval {Class::MOP::load_class( $self->model_class ); };

    unless ($ok){
      print STDERR "Creating target class ". $self->model_class . "\n"
        if $self->debug_mode;
      Object->meta->create($self->model_class, superclasses => [ Object ]);
    }
  };

  implements submodel_classname_from_source_name => as {
    my ($self, $moniker) = @_;
    return join "::", $self->model_class, $moniker;
  };

  implements classname_for_collection_of => as {
    my ($self, $object_class) = @_;
    return "${object_class}::Collection";
  };

  #requires domain_model everything else optional
  implements reflect_model => as {
    my ($self, %opts) = @_;
    my $meta = $self->model_class->meta;
    my $source  = delete $opts{domain_model_class};
    my $dm_name = delete $opts{domain_model_name};
    my $dm_args = delete $opts{domain_model_args} || {};

    my $reflect_submodels = delete $opts{reflect_submodels};
    my %exclude_submodels = map {$_ => 1}
      ref $opts{exclude_submodels} ? @{$opts{exclude_submodels}} : ();

    Class::MOP::load_class($source);
    my $make_immutable = $self->make_classes_immutable || $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;

    unless( $dm_name ){
      $dm_name = "_".$source;
      $dm_name =~ s/::/_/g;
    }

    print STDERR "Reflecting model '$source' with domain model '$dm_name'\n"
      if $self->debug_mode;
    $meta->add_domain_model($dm_name, is => 'rw', required => 1, %$dm_args);

    #reflect all applicable submodels on undef
    @$reflect_submodels = $source->sources unless ref $reflect_submodels;
    @$reflect_submodels = grep { !$exclude_submodels{$_} } @$reflect_submodels;

    for my $moniker (@$reflect_submodels){
      my $source_class = $source->class($moniker);
      print STDERR "... and submodel '$source_class'\n" if $self->debug_mode;
      my $sub_meta = $self->reflect_submodel(domain_model_class => $source_class);
      my $col_meta = $self->reflect_collection_for(object_class => $sub_meta->name);

      $self->add_submodel_to_model(
                                   source_name       => $moniker,
                                   domain_model_name => $dm_name,
                                   collection_class  => $col_meta->name,
                                  );
    }

    $meta->make_immutable if $make_immutable;
    return $meta;
  };

  #XXX I could make domain_model_name by exploiting the metadata in the
  #DomainModelAttribute, I'm just waiting to properly redesign DMAttr,
  #it'll be good, I promise.

  implements add_submodel_to_model => as {
    my($self, %opts) = @_;
    my $reader  = $opts{reader};
    my $moniker = $opts{source_name};
    my $dm_name = $opts{domain_model_name};
    my $c_class = $opts{collection_class};
    my $name    = $opts{attribute_name} || $moniker;
    my $meta    = $self->model_class->meta;

    my $make_immutable = $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;

    unless ($reader){
      $reader = $moniker;
      $reader =~ s/([a-z0-9])([A-Z])/${1}_${2}/g ;
      $reader = lc($reader) . "_collection";
    }

    my %attr_opts =
      (
       lazy           => 1,
       isa            => $c_class,
       required       => 1,
       reader         => $reader,
       predicate      => "has_${moniker}",
       domain_model   => $dm_name,
       orig_attr_name => $moniker,
       default        => sub {
         $c_class->new(_source_resultset => shift->$dm_name->resultset($moniker) );
       },
      );
    print STDERR "... linking submodel '$c_class' through method '$reader'\n"
      if $self->debug_mode;

    my $attr = $meta->add_attribute($moniker, %attr_opts);
    $meta->make_immutable if $make_immutable;
    return $attr;
  };

  # requires #object_class, everything else optional
  implements reflect_collection_for => as {
    my ($self, %opts) = @_;
    my $object  = delete $opts{object_class};
    my $base    = delete $opts{base} || ResultSet;
    my $actions = delete $opts{reflect_actions} || $self->default_collection_actions;
    my $class   = $opts{class} || $self->classname_for_collection_of($object);

    Class::MOP::load_class($base);
    my $meta = eval { Class::MOP::load_class($class) } ?
      $class->meta : $base->meta->create($class, superclasses =>[ $base ]);
    my $make_immutable = $self->make_classes_immutable || $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;

    $meta->add_method(_build_im_class => sub{ $object } );
    print STDERR "... Reflecting collection of $object as $class\n"
      if $self->debug_mode;

    for my $action (@$actions){
      unless (ref $action){
        my $default = grep {$_->{name} eq $action} @{ $self->default_collection_actions };
        confess("unable to reflect action $action") unless $default;
        $action = $default;
      }
      $self->reflect_submodel_action(submodel_class => $object, %$action);
      my $act_args =  sub {   #override target model for this action
        my $super = shift;
        return { %{$super->(@_)},($_[1] eq $action->{name} ?
                                  (target_model => $_[0]->_source_resultset) : () )};
      };
      $meta->add_around_method_modifier('_default_action_args_for', $act_args);
    }

    $meta->make_immutable if $make_immutable;
    return $meta;
  };

  #requires domain_model_class everything else optional
  implements reflect_submodel => as {
    my ($self, %opts) = @_;
    my $source  = delete $opts{domain_model_class};
    my $base    = delete $opts{base} || Object;
    my $dm_name = delete $opts{domain_model_name};
    my $dm_opts = delete $opts{domain_model_args} || {};
    my $inflate = exists $opts{inflate} ? delete $opts{inflate} : 1;
    my $class   = delete $opts{class} ||
      $self->submodel_classname_from_source_name($source->source_name);
    my $actions = delete $opts{reflect_actions} || $self->default_object_actions;

    #create the custom class
    Class::MOP::load_class($base);
    my $meta = eval { Class::MOP::load_class($class) } ?
      $class->meta : $base->meta->create($class, superclasses =>[ $base ]);
    my $make_immutable = $self->make_classes_immutable || $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;

    #create the domain model
    unless( $dm_name ){
      ($dm_name) = ($source =~ /::([\w_\-]+)$/); #XXX be smarter at some point
      $dm_name =~ s/([a-z0-9])([A-Z])/${1}_${2}/g ;
      $dm_name = "_" . lc($dm_name) . "_store";
    }

    $dm_opts->{isa} = $source;
    $dm_opts->{is}       ||= 'rw';
    $dm_opts->{required} ||= 1;
    my $dm_attr = $meta->add_domain_model($dm_name, %$dm_opts);

    #Inflate the row into an IM object directly from DBIC
    if( $inflate ){
      my $inflate_method = sub {
        my $class = shift; my ($src) = @_;
        $src = $src->resolve if $src->isa('DBIx::Class::ResultSourceHandle');
        $class->new($dm_name, $src->result_class->inflate_result(@_));
      };
      $meta->add_method('inflate_result', $inflate_method);
    }

    #attribute reflection
    my $reflect_attrs = delete $opts{reflect_attributes};
    my %exclude_attrs =
      map {$_ => 1} ref $opts{exclude_attributes} ? @{$opts{exclude_attributes}} : ();

    #reflect all applicable attributes on undef
    $reflect_attrs = [map {$_->name} $source->meta->compute_all_applicable_attributes]
      unless ref $reflect_attrs;
    @$reflect_attrs = grep { !$exclude_attrs{$_} } @$reflect_attrs;

    for my $attr_name (@$reflect_attrs){
      $self->reflect_submodel_attribute(
                                        class => $class,
                                        attribute_name => $attr_name,
                                        domain_model_name => $dm_name
                                       );
    }

    for my $action (@$actions){
      unless (ref $action){
        my $default = grep {$_->{name} eq $action} @{ $self->default_object_actions };
        confess("unable to reflect action $action") unless $default;
        $action = $default;
      }
      $self->reflect_submodel_action(submodel_class => $class, %$action);
      my $dm = $dm_attr->get_read_method;
      my $act_args = sub {   #override target model for this action
        my $super = shift;
        return { %{ $super->(@_) },
            ($_[1] eq $action->{name} ? (target_model => $_[0]->$dm) : () ) };
      };
      $meta->add_around_method_modifier('_default_action_args_for', $act_args);
    }

    $meta->make_immutable if $make_immutable;
    return $meta;
  };

  # needs class, attribute_name domain_model_name
  implements reflect_submodel_attribute => as {
    my ($self, %opts) = @_;
    my $meta =  $opts{class}->meta;
    my $attr_opts = $self->parameters_for_submodel_attr(%opts);

    my $make_immutable = $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;
    my $attr = $meta->add_attribute($opts{attribute_name}, %$attr_opts);
    $meta->make_immutable if $make_immutable;

    return $attr;
  };

  # needs class, attribute_name domain_model_name
  implements parameters_for_submodel_attr => as {
    my ($self, %opts) = @_;

    my $attr_name = $opts{attribute_name};
    my $dm_name   = $opts{domain_model_name};
    my $domain    = $opts{domain_model_class};
    $domain ||= $opts{class}->meta->find_attribute_by_name($dm_name)->_isa_metadata;
    my $from_attr = $domain->meta->find_attribute_by_name($attr_name);
    my $source    = $domain->result_source_instance;

    #default options. lazy build but no outsider method
    my %attr_opts = ( is => 'ro', lazy => 1, required => 1,
                      clearer   => "_clear_${attr_name}",
                      predicate => "has_${attr_name}",
                      domain_model   => $dm_name,
                      orig_attr_name => $attr_name,
                    );

    #m2m / has_many
    my $constraint_is_ArrayRef =
      $from_attr->type_constraint->name eq 'ArrayRef' ||
        $from_attr->type_constraint->is_subtype_of('ArrayRef');

    if( my $rel_info = $source->relationship_info($attr_name) ){
      my $rel_accessor = $rel_info->{attrs}->{accessor};
      my $rel_moniker  = $rel_info->{class}->source_name;

      if($rel_accessor eq 'multi' && $constraint_is_ArrayRef) {
        #has_many
        my $sm = $self->submodel_classname_from_source_name($rel_moniker);
        #type constraint is a collection, and default builds it
        $attr_opts{isa} = $self->classname_for_collection_of($sm);
        $attr_opts{default} = sub {
          my $rs = shift->$dm_name->related_resultset($attr_name);
          return $attr_opts{isa}->new(_source_resultset => $rs);
        };
      } elsif( $rel_accessor eq 'single') {
        #belongs_to
        #type constraint is the foreign IM object, default inflates it
        $attr_opts{isa} = $self->submodel_classname_from_source_name($rel_moniker);
        $attr_opts{default} = sub {
          shift->$dm_name
            ->find_related($attr_name, {},{result_class => $attr_opts{isa}});
        };
      }
    } elsif( $constraint_is_ArrayRef && $attr_name =~ m/^(.*)_list$/) {
      #m2m magic
      my $mm_name = $1;
      my $link_table = "links_to_${mm_name}_list";
      my ($hm_source, $far_side);
      eval { $hm_source = $source->related_source($link_table); }
        || confess "Can't find ${link_table} has_many for ${mm_name}_list";
      eval { $far_side = $hm_source->related_source($mm_name); }
        || confess "Can't find ${mm_name} belongs_to on ".$hm_source->result_class
          ." traversing many-many for ${mm_name}_list";

      my $sm = $self->submodel_classname_from_source_name($far_side->source_name);
      $attr_opts{isa} = $self->classname_for_collection_of($sm);

      #proper collections will remove the result_class uglyness.
      $attr_opts{default} = sub {
        my $rs = shift->$dm_name->result_source->related_source($link_table)
          ->related_source($mm_name)->resultset;
        return $attr_opts{isa}->new(_source_resultset => $rs);
      };
    } else {
      #no rel
      my $reader = $from_attr->get_read_method;
      $attr_opts{isa} = $from_attr->_isa_metadata;
      $attr_opts{default} = sub{ shift->$dm_name->$reader };
    }
    return \%attr_opts;
  };


  #XXX change superclasses to "base" ?
  implements reflect_submodel_action => as{
    my($self, %opts) = @_;
    my $im_class = delete $opts{submodel_class};
    my $base     = delete $opts{base} || Action;
    my $attrs    = delete $opts{attributes};
    my $name     = delete $opts{name};
    my $class    = delete $opts{class} || $im_class->_default_action_class_for($name);

    print STDERR "... Reflecting action $name for $im_class as $class\n"
      if $self->debug_mode;

    Class::MOP::load_class($_) for($base, $im_class);
    $attrs = [ map{$_->name} $im_class->parameter_attributes] unless ref $attrs;
    my $im_meta = $im_class->meta;

    #create the class
    my $meta = eval { Class::MOP::load_class($class) } ?
      $class->meta : $base->meta->create($class, superclasses => [$base]);
    my $make_immutable = $self->make_classes_immutable || $meta->is_immutable;
    $meta->make_mutable if $meta->is_immutable;

    foreach my $attr_name (@$attrs){
      my $im_attr   = $im_meta->find_attribute_by_name($attr_name);
      my $dm_attr   = $im_meta->find_attribute_by_name($im_attr->domain_model);
      my $dm_meta   = $dm_attr->_isa_metadata->meta;
      my $from_attr = $dm_meta->find_attribute_by_name($im_attr->orig_attr_name);

      #Don't reflect read-only attributes to actions
      unless( $from_attr->get_write_method ) {
        print STDERR "..... not relecting read-only attribute ${attr_name} to ${class}"
          if $self->debug_mode;
        next;
      }

      my $attr_params = $self->parameters_for_submodel_action_attribute
        ( submodel_class => $im_class, attribute_name => $attr_name );

      #add the attribute to the class
      $meta->add_attribute( $attr_name => %$attr_params);
    }

    $meta->make_immutable if $make_immutable;
    return $meta;
  };


  implements parameters_for_submodel_action_attribute => as {
    my ($self, %opts) = @_;

    #XXX we need the domain model name so we can do valid_values correcty....
    #otherwise we could do away with submodel_class and use domain_model_class instead
    #we need for domain_model to be set on the attr which we may not be sure of
    my $submodel  = delete $opts{submodel_class};
    my $sm_meta   = $submodel->meta;
    my $attr_name = delete $opts{attribute_name};
    my $dm_name   = $sm_meta->find_attribute_by_name($attr_name)->domain_model;
    my $domain    = $sm_meta->find_attribute_by_name($dm_name)->_isa_metadata;
    my $from_attr = $domain->meta->find_attribute_by_name($attr_name);
    my $source    = $domain->result_source_instance;

    confess("${attr_name} is not writeable and can not be reflected")
      unless $from_attr->get_write_method;

    my %attr_opts = (
                     is        => 'rw',
                     isa       => $from_attr->_isa_metadata,
                     required  => $from_attr->is_required,
                     predicate => "has_${attr_name}",
                    );

    if ($attr_opts{required}) {
      $attr_opts{lazy} = 1;
      $attr_opts{default} = $from_attr->has_default ? $from_attr->default :
        sub{confess("${attr_name} must be provided before calling reader")};
    }

    #test for relationships
    my $constraint_is_ArrayRef =
      $from_attr->type_constraint->name eq 'ArrayRef' ||
        $from_attr->type_constraint->is_subtype_of('ArrayRef');

    if (my $rel_info = $source->relationship_info($attr_name)) {
      my $rel_accessor = $rel_info->{attrs}->{accessor};

      if($rel_accessor eq 'multi' && $constraint_is_ArrayRef) {
        confess "${attr_name} is a rw has_many, this won't work.";
      } elsif( $rel_accessor eq 'single') {
        $attr_opts{valid_values} = sub {
          shift->target_model->result_source->related_source($attr_name)->resultset;
        };
      }
    } elsif ( $constraint_is_ArrayRef && $attr_name =~ m/^(.*)_list$/) {
      my $mm_name = $1;
      my $link_table = "links_to_${mm_name}_list";
      my ($hm_source, $far_side);
      eval { $hm_source = $source->related_source($link_table); }
        || confess "Can't find ${link_table} has_many for ${mm_name}_list";
      eval { $far_side = $hm_source->related_source($mm_name); }
        || confess "Can't find ${mm_name} belongs_to on ".$hm_source->result_class
          ." traversing many-many for ${mm_name}_list";

      $attr_opts{default} = sub { [] };
      $attr_opts{valid_values} = sub {
        shift->$dm_name->result_source->related_source($link_table)
          ->related_source($mm_name)->resultset;
      };
    }
    return \%attr_opts;
  };

};

1;


=head1 NAME

Reaction::InterfaceModel::Reflector::DBIC - Autogenerate an Interface Model from
a DBIx::Class Schema.

=head1 DESCRIPTION

This class will reflect a L<DBIx::Class::Schema> to a C<Reaction::InterfaceModel::Object>.
It can aid you in creating interface models, collections, and associated actions rooted
in DBIC storage.

=head1 SYNOPSYS

  #model_class is the namespace where our reflected interface model will be created
  my $reflector = Reaction::InterfaceModel::Reflector::DBIC
    ->new(model_class => 'RTest::TestIM');

  #Example 1: Reflect all submodels (result sources / tables)
  #domain_model_class ISA DBIx::Class::Schema
  $reflector->reflect_model(domain_model_class => 'RTest::TestDB');
  #the '_RTest_TestDB' attribute is created automatically to store the domain model
  RTest::TestIM->new(_RTest_TestDB => RTest::TestDB->connect(...) );

  #Example 2: Don't reflect the FooBaz submodel
  $reflector->reflect_model(
                            domain_model_class => 'RTest::TestDB',
                            exclude_submodels  => ['FooBaz'],
                           );
  RTest::TestIM->new(_RTest_TestDB => RTest::TestDB->connect(...) );

  #Example 3: Only reflect Foo, Bar, and Baz
  $reflector->reflect_model(
                            domain_model_class => 'RTest::TestDB',
                            reflect_submodels  => [qw/Foo Bar Baz/],
                           );
  RTest::TestIM->new(_RTest_TestDB => RTest::TestDB->connect(...) );

  #Example 4: Explicit domain_model_name
  $reflector->reflect_model(
                            domain_model_class => 'RTest::TestDB',
                            domain_model_name  => '_rtest_testdb',
                           );
  RTest::TestIM->new(_rtest_testdb => RTest::TestDB->connect(...) );

=head1 A NOTE ABOUT REFLECTION

This class is meant as an aid in rapid prototyping and CRUD functionality creation.
While parts of it should be useful for projects of any size, any non-trivial
application will likely require some hand-coding or tweaking to get the most out of
this tool. Reflection, like CRUD, is not a magic bullet. It's just a way to help you
eliminate repetitive and unnecessary coding.

=head1 OVERVIEW & DEFAULT NAMING CONVENTIONS

By default (you can override this behavior later), The top-level model (the one
corresponding to your schema) will be reflected to the class name you provide at
instantiation, submodels to the model name plus the name of the source, and collections
to the name of the submodel plus "Collection". Action names, if not specified directly
will be determined by using the submodel's "_action_name_for" method.

=head2 A Note about Immutable

The methods that modify classes will check for class immutability and unlock classes
for modification if they are immutable. Classes will be locked again after they are
modified if they were locked at the start.

=head1 ATTRIBUTES

=head2 model_class

Required, Read-only. This is the name of the class where your top model will be created
and the namespace under which all your submodels, actions, collections will be
created.

=head2 make_classes_immutable

Read-Write boolean, defaults to false. If this is set to true, after classes are
created they will be made immutable.

=head2 default_object_actions

=head2 default_collection_actions

These hold an ArrayRef of action prototypes. An Action prototype is a hashref
with at least 2 keys, "name" and "base" the latter which is an otional superclass
for this action. By default a "Create" action is reflected for Collections and
"Update" and "Delete" actions for IM Objects. You may add here any
attribute that reflect_submodel_action takes, i.e. for an action that doesn't need
any reflected attributes, like Delete, use C<attributes =E<gt> []>.

=head2 debug_mode

Read-Write boolean, defaults to false. In the future this will provide valuable
information at runtime, however that has not yet been implemented.

=head1 METHODS

=head2 submodel_classname_from_source_name $source_name

Generate the classname for a submodel from the result source's name.

=head2 classname_for_collection_for $object_class

Returns the classname for a collection of a certain submodel. Currently it just appends
"::Collection"

=head2 reflect_model %args

=over 4

=item C<domain_model_class> - Required, this is the classname of your Schema

=item C<domain_model_name>  - The name to use when creating the domain model attribute
If you don't supply this one will automatically be generated by prefacing the domain_model_class
with an underscore and replacing all instances of "::", with "_"

=item C<domain_model_args>  - Any other optional arguments suitable for passing to C<add_attribute>

=item C<reflect_submodels>  - An ArrayRef of the source names of the submodels to reflect.
If the value is not a reference it will attempt to reflect all sources. In the future
there may be regex support

=item C<exclude_submodels>  - ArrayRef of submodels to exclude from reflection. In the
future there may be regex support

=back

This method will query the schema given to it and reflect all appropriate submodels as
well as calling C<add_submodel_to_model> to create an attribute in the reflected model
which returns an appropriate collection.

=head2 add_submodel_to_model %args

=over 4

=item C<source_name> - The DBIC source name for this submodel

=item C<collection_class> - The classname for the collection type for this submodel.

=item C<attribute_name> - The name of the attribute to create in the model to represent
this submodel. If one is not supplied the source name will be used.

=item C<domain_model_name> - The attribute name of the domain model where the schema is
located. In the future this may be optional since it can be detected, but it needs to
wait until some changes are made to the attribute metaclasses.

=item C<reader> - The read method for the submodel attribute. If one is not provided,
a lower case version of the source name with underscores separating previous cases
of a camel-case word change and "_collection" appended will be used.  Examples:
"FooBar" becomes C<foo_bar_collection> and "Foo" becomes C<foo_collection>.

=back

This will create a read-only attribute in your main model that will return a
collection of the submodel type when the reader is called. This will return the same
collection every time, not a fresh one. This may change in the future, but I really
see no need for it right now.

=head2 reflect_collection_for \%args

=over 4

=item C<object_class> - Required. The class ob objects this collection will be representing

=item C<base> - Optional, if you'd like to use a different base for the Collection other
than L<Reaction::InterfaceModel::Collection::Virtual::ResultSet> you can set it here

=item C<reflect_actions> - Action prototypes for the actions you wish to reflect for
this collection. If nothing is specified then C<default_collection_actions> is used.
An Action prototype is a hashref with at least 2 keys, "name" and "base" the latter
is the superclass for this action. Using an empty array reference would reflect nothing.

=item C<class> - The desired classname for this collection. If none is provided, then
the value returned by C<classname_for_collection_of> is used.

=back

This method will create a new collection class that inherits from C<base> and overrides
C<_build_im_class> to return C<object_class>. Additionally it will automatically
override C<_default_action_args_for> as needed for reflected actions.

=head2 reflect_submodel \%args

=over 4

=item C<domain_model_class> - The class from which the submodel will be created, or your
source class, e.g. MyApp::Schema::Foo

=item C<base> - Optional, if you'd like to use a different base other than
L<Reaction::InterfaceModel::Object>

=item C<domain_model_name> - the name to use for your domain model attribute. If one
is not provided, a lower case version of the source name begining with an underscore
and with underscores separating previous cases of a camel-case word change and
"_store" appended will be used.
Examples: "FooBar" becomes C<_foo_bar_store> and "Foo" becomes C<_foo_store>.

=item C<domain_model_args> - Any additional arguments you may want to pass to the domain
model when it is created e.g. C<handles>

=item C<inflate> - unless this is set to zero an inflate_result method will be created.

=item C<class> - the name of the submodel class created, if you don't specify it the
value returned by C<submodel_classname_from_source_name> will be used

=item C<reflect_actions> - Action prototypes for the actions you wish to reflect for
this collection. If nothing is specified then C<default_object_actions> is used.
An Action prototype is a hashref with at least 2 keys, "name" and "base" the latter
is the superclass for this action. Using an empty array reference would reflect nothing.

=item C<reflect_attributes> - an arrayref of the names of the attributes you want to
reflect, if this is not an arrayref it will attempt to reflect all attributes,
if you wish to not reflect anything pass it an empty arrayref

=item C<exclude_attributes> - an arrayref of the names of the attributes to exclude.

=back

This method will create the submodel class, copy the applicable attributes and create
the appropriate domain model attribute as well as create the necessary actions and
perform the necessary overrides to C<_default_action_args_for>

=head2 reflect_submodel_attribute \%args

Takes the same arguments as C<parameters_for_submodel_attribute>.

Reflect this attribute and add it to the submodel class.

=head2 parameters_for_submodel_attribute \%args

=over 4

=item C<class> - the submodel class

=item C<attribute_name> - the name of the attribute you want to reflect

=item C<domain_model_class> - the class where we are copying the attribute from.
If not specified, the type constraint on the domain model attribute will be used

=item C<domain_model_name> - the name of the domain model attribute.

=back

This method determines the parameters necessary for reflecting the argument. Most
of the magic here is so that relations can be accurately reflected so that many-to-one
relationships can return submodel objects and one-to-many and many-to-many
relationships can return collections. By default all reflected attributes will be built
lazily from their parent domain model.

=head2 reflect_submodel_action \%args

=over 4

=item C<submodel_class> - the submodel class this action will be associated with

=item C<base> - superclass for the action class created

=item C<attributes> - a list of the names of attributes to mirror from the submodel.
A blank list signifies nothing, and a non list value will cause it to reflect all
writeable parameter attributes from the submodel.

=item C<name> - the name of the action, required.

=item C<class> - optional, the name of the action class. By default it will query the
submodel class through the method C<_default_action_class_for>

=back

Create an action class that acts on the submodel from a base class. This is most useful
for CRUD and similar actions.

=head2 parameters_for_submodel_action_attribute \ %args

=over 4

=item C<attribute_name> - name of the attribute being reflected

=item C<submodel_class> - the submodel where this attribute is located

=back

Create the correct parameters for the attribute being created in the action, including
valid_values, and correct handling of relationships and defaults.

=head1 PRIVATE METHODS

=head2 BUILD

Load the C<model_class> if it exists or create one if it does not.

=head1 TODO

Allow reflect_* and exclude_* methods to take compiled regular expressions, tidy up
argument names and method names, mace docs decent, make more tests, try to figure out
more through introspection to require less arguments, proper checking of values passed
and throwing of errors when garbage is passed in.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

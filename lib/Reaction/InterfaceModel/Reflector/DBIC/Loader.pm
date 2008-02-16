package Reaction::InterfaceModel::Reflector::DBIC::Loader;

use aliased 'Reaction::InterfaceModel::Action::DBIC::ResultSet::Create';
use aliased 'Reaction::InterfaceModel::Action::DBIC::ResultSet::DeleteAll';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Update';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Delete';

use aliased 'Reaction::InterfaceModel::Collection::Virtual::ResultSet';
use aliased 'Reaction::InterfaceModel::Object';
use aliased 'Reaction::InterfaceModel::Action';
use Reaction::Class;
use Class::MOP;

use Catalyst::Utils;

class Loader, which {

  #user defined actions and prototypes
  has object_actions     => (isa => "HashRef", is => "rw", lazy_build => 1);
  has collection_actions => (isa => "HashRef", is => "rw", lazy_build => 1);

  #which actions to create by default
  has default_object_actions     => (isa => "ArrayRef", is => "rw", lazy_build => 1);
  has default_collection_actions => (isa => "ArrayRef", is => "rw", lazy_build => 1);

  #builtin actions and prototypes
  has builtin_object_actions     => (isa => "HashRef", is => "rw", lazy_build => 1);
  has builtin_collection_actions => (isa => "HashRef", is => "rw", lazy_build => 1);

  implements _build_object_actions     => as { {} };
  implements _build_collection_actions => as { {} };

  implements _build_default_object_actions     => as { [ qw/Update Delete/ ] };
  implements _build_default_collection_actions => as { [ qw/Create DeleteAll/ ] };

  implements _build_builtin_object_actions => as {
    {
      Update => { name => 'Update', base => Update },
      Delete => { name => 'Delete', base => Delete, attributes => [] },
    };
  };

  implements _build_builtin_collection_actions => as {
    {
      Create    => {name => 'Create',    base => Create    },
      DeleteAll => {name => 'DeleteAll', base => DeleteAll, attributes => [] }
    };
  };

  implements _all_object_actions => as {
   my $self = shift;
    return $self->merge_hashes
      ($self->builtin_object_actions, $self->object_actions);
  };

  implements _all_collection_actions => as {
    my $self = shift;
    return $self->merge_hashes
      ($self->builtin_collection_actions, $self->collection_actions);
  };

  implements dm_name_from_class_name => as {
    my($self, $class) = @_;
    confess("wrong arguments") unless $class;
    $class =~ s/::/_/g;
    $class = "_" . lc($class) . "_store";
    return $class;
  };

  implements dm_name_from_source_name => as {
    my($self, $source) = @_;
    confess("wrong arguments") unless $source;
    $source =~ s/([a-z0-9])([A-Z])/${1}_${2}/g ;
    $source = "_" . lc($source) . "_store";
    return $source;
  };

  implements class_name_from_source_name => as {
    my ($self, $model_class, $source_name) = @_;
    confess("wrong arguments") unless $model_class && $source_name;
    return join "::", $model_class, $source_name;
  };

  implements class_name_for_collection_of => as {
    my ($self, $object_class) = @_;
    confess("wrong arguments") unless $object_class;
    return "${object_class}::Collection";
  };

  implements merge_hashes => as {
    my($self, $left, $right) = @_;
    return Catalyst::Utils::merge_hashes($left, $right);
  };

  implements parse_reflect_rules => as {
    my ($self, $rules, $haystack) = @_;
    confess('$rules must be an array reference')    unless ref $rules    eq 'ARRAY';
    confess('$haystack must be an array reference') unless ref $haystack eq 'ARRAY';

    my $needles = {};
    my (@exclude, @include, $global_opts);
    if(@$rules == 2 && $rules->[0] eq '-exclude'){
      push(@exclude, (ref $rules->[1] eq 'ARRAY' ? @{$rules->[1]} : $rules->[1]));
    } else {
      for my $rule ( @$rules ){
        if (ref $rule eq 'ARRAY' && $rule->[0] eq '-exclude'){
          push(@exclude, (ref $rule->[1] eq 'ARRAY' ? @{$rule->[1]} : $rule->[1]));
        } elsif( ref $rule eq 'HASH' ){
          $global_opts = ref $global_opts eq 'HASH' ?
            $self->merge_hashes($global_opts, $rule) : $rule;
        } else {
          push(@include, $rule);
        }
      }
    }
    my $check_exclude = sub{
      for my $rule (@exclude){
        return 1 if(ref $rule eq 'Regexp' ? $_[0] =~ /$rule/ : $_[0] eq $rule);
      }
      return;
    };

    @$haystack = grep { !$check_exclude->($_) } @$haystack;
    $self->merge_reflect_rules(\@include, $needles, $haystack, $global_opts);
    return $needles;
  };

  implements merge_reflect_rules => as {
    my ($self, $rules, $needles, $haystack, $local_opts) = @_;
    for my $rule ( @$rules ){
      if(!ref $rule && ( grep {$rule eq $_} @$haystack ) ){
        $needles->{$rule} = defined $needles->{$rule} ?
          $self->merge_hashes($needles->{$rule}, $local_opts) : $local_opts;
      } elsif( ref $rule eq 'Regexp' ){
        for my $match ( grep { /$rule/ } @$haystack ){
          $needles->{$match} = defined $needles->{$match} ?
            $self->merge_hashes($needles->{$match}, $local_opts) : $local_opts;
        }
      } elsif( ref $rule eq 'ARRAY' ){
        my $opts;
        $opts = pop(@$rule) if @$rule > 1 and ref $rule->[$#$rule] eq 'HASH';
        $opts = $self->merge_hashes($local_opts, $opts) if defined $local_opts;
        $self->merge_reflect_rules($rule, $needles, $haystack, $opts);
      }
    }
  };



  has packages => (
                   isa => 'HashRef',
                   required => 1,
                   is => 'ro',
                   default => sub{ {} },
                  );

  implements add_to_package => as {
    my ($self, $package, $args) = @_;
    my $orig = $self->packages->{$package} || {};
    my $merged = $self->merge_hashes($orig,$args || {});
    %$orig = %$merged; #don't break other refs that may be laying around
    return $orig;
  };

  implements reflect_schema => as {
    my ($self, %opts) = @_;
    my $base    = delete $opts{base} || Object;
    my $model   = delete $opts{model_class};
    my $schema  = delete $opts{schema_class};
    my $dm_name = delete $opts{domain_model_name};
    my $dm_args = delete $opts{domain_model_args} || {};
    $dm_name ||= $self->dm_name_from_class_name($schema);

    #load all necessary classes
    confess("model_class and schema_class are required parameters")
      unless($model && $schema);
    Class::MOP::load_class( $schema );

    my $package_opts = {name => $model, superclasses => $base };
    my $package = $self->add_to_package($model, $package_opts);

    # sources => undef,              #default to qr/./
    # sources => [],                 #default to nothing
    # sources => qr//,               #DWIM, treated as [qr//]
    # sources => [{...}]             #DWIM, treat as [qr/./, {...} ]
    # sources => [[-exclude => ...]] #DWIM, treat as [qr/./, [-exclude => ...]]
    my $haystack = [ $schema->sources ];

    my $rules    = delete $opts{sources};
    if(!defined $rules){
      $rules = [qr/./];
    } elsif( ref $rules eq 'Regexp'){
      $rules = [ $rules ];
    } elsif( ref $rules eq 'ARRAY' && @$rules){
      #don't add a qr/./ rule if we have at least one match rule
      push(@$rules, qr/./) unless grep {(ref $_ eq 'ARRAY' && $_->[0] ne '-exclude')
                                          || !ref $_  || ref $_ eq 'Regexp'} @$rules;
    }

    my $sources = $self->parse_reflect_rules($rules, $haystack);


    my $domain_model = {is => 'rw', isa => $schema, required => 1, %$dm_args};
    $self->add_to_package($model, {domain_models => {$dm_name => $domain_model}});

    #push these to packages
    for my $source_name (keys %$sources){
      my $source_opts = $sources->{$source_name} || {};
      $self->reflect_source(
                            source_name  => $source_name,
                            parent_class => $model,
                            schema_class => $schema,
                            source_class => $schema->class($source_name),
                            parent_domain_model_name => $dm_name,
                            %$source_opts
                           );
    }
  };

  implements _compute_source_options => as {
    my ($self, %opts) = @_;
    my $schema       = delete $opts{schema_class};
    my $source_name  = delete $opts{source_name};
    my $source_class = delete $opts{source_class};
    my $parent       = delete $opts{parent_class};
    my $parent_dm    = delete $opts{parent_domain_model_name};

    #this is the part where I hate my life for promissing all sorts of DWIMery
    confess("parent_class and source_name or source_class are required parameters")
      unless($parent && ($source_name || $source_class));

  OUTER: until( $schema && $source_name && $source_class && $parent_dm ){
      if( $schema && !$source_name){
        next OUTER if $source_name = $source_class->result_source_instance->source_name;
      } elsif( $schema && !$source_class){
        next OUTER if $source_class = eval { $schema->class($source_name) };
      }

      if($source_class && (!$schema || !$source_name)){
        if(!$schema){
          $schema = $source_class->result_source_instance->schema;
          next OUTER if $schema && Class::MOP::load_class($schema);
        }
        if(!$source_name){
          $source_name = $source_class->result_source_instance->source_name;
          next OUTER if $source_name;
        }
      }

      my $dms = $self->packages->{$parent}->{domain_models};
      my @haystack = $parent_dm ? $dms->{$parent_dm} : keys %$dms;

      #there's a lot of guessing going on, but it should work fine on most cases
    INNER: for my $needle (@haystack){
        my $isa = $dms->{$needle}->{isa};
        #we really have to clean up this nastiness and find a way to bring TCs
        #into the mix here. To do: ( &constraint_is_dbix_class_schema )
        next INNER unless Class::MOP::load_class( $isa );
        next INNER unless $isa->isa('DBIx::Class::Schema');
        if(!$parent_dm && $schema && $isa eq $schema){
          $parent_dm = $needle->name;
          next OUTER;
        }

        if( $source_name ){
          my $src_class = eval{ $isa->class($source_name) };
          next INNER unless $src_class;
          next INNER if($source_class && $source_class ne $src_class);
          $schema = $isa;
          $parent_dm = $needle->name;
          $source_class = $src_class;
          next OUTER;
        }
      }

      #do we even need to go this far?
      if( !$parent_dm && $schema ){
        my $tentative = $self->dm_name_from_class_name($schema);
        $parent_dm = $tentative if grep{$_ eq $tentative} @haystack;
      }

      confess("Could not determine options automatically from: schema " .
              "'${schema}', source_name '${source_name}', source_class " .
              "'${source_class}', parent_domain_model_name '${parent_dm}'");
    }

    return {
            source_name  => $source_name,
            schema_class => $schema,
            source_class => $source_class,
            parent_class => $parent,
            parent_domain_model_name => $parent_dm,
           };
  };

  implements _class_to_attribute_name => as {
    my ( $self, $str ) = @_;
    confess("wrong arguments passed for _class_to_attribute_name") unless $str;
    return join('_', map lc, split(/::|(?<=[a-z0-9])(?=[A-Z])/, $str))
  };

  implements add_source => as {
    my ($self, %opts) = @_;

    my $model      = delete $opts{model_class};
    my $reader     = delete $opts{reader};
    my $source     = delete $opts{source_name};
    my $dm_name    = delete $opts{domain_model_name};
    my $collection = delete $opts{collection_class};
    my $name       = delete $opts{attribute_name} || $source;

    confess("model_class and source_name are required parameters")
      unless $model && $source;

    unless( $collection ){
      my $object = $self->class_name_from_source_name($model, $source);
      $collection = $self->class_name_for_collection_of($object);
    }
    unless( $reader ){
      $reader = $source;
      $reader =~ s/([a-z0-9])([A-Z])/${1}_${2}/g ;
      $reader = $self->_class_to_attribute_name($reader) . "_collection";
    }
    unless( $dm_name ){
      my $dms = $self->packages->{$model}->{domain_models};
      my @haystack = keys %$dms;
      #again, here i could use that constraint_is_dbix_class_schema thing
      if( @haystack > 1 ){
        @haystack =
          grep { $dms->{$_}{isa}->isa('DBIx::Class::Schema') }
            @haystack;
      }
      if(@haystack == 1){
        $dm_name = $haystack[0];
      } elsif(@haystack > 1){
        confess("Failed to automatically determine domain_model_name. More than one " .
                "possible match (".(join ", ", map{"'${_}'"} @haystack).")");
      } else {
        confess("Failed to automatically determine domain_model_name. No matches.");
      }
    }

    my $default_sub = qq^  sub {
      my \$self = \$_[0];
      return $collection->new
        (
         _source_resultset => \$self->$dm_name->resultset('${source}'),
         _parent => \$self,
        );
    };^ ;
    my %attr_opts =
      (
       lazy           => 1,
       required       => 1,
       isa            => $collection,
       reader         => $reader,
       predicate      => "has_" . $self->_class_to_attribute_name($name) ,
       domain_model   => $dm_name,
       orig_attr_name => $source,
       default        => \$default_sub, #scalar ref means it's code
      );

    $self->add_to_package
      ($model, {parameter_attributes => {$name => \%attr_opts}});
  };

  implements reflect_source => as {
    my ($self, %opts) = @_;
    my $collection  = delete $opts{collection} || {};
    %opts = %{ $self->merge_hashes(\%opts, $self->_compute_source_options(%opts)) };

    my $object_name     = $self->reflect_source_object(%opts);
    my $collection_name = $self->reflect_source_collection
      (
       object_class => $object_name,
       source_class => $opts{source_class},
       %$collection,
      );

    $self->add_source(
                      model_class       => $opts{parent_class},
                      source_name       => $opts{source_name},
                      domain_model_name => $opts{parent_domain_model_name},
                      collection_class  => $collection_name,
                     );
  };

  implements reflect_source_collection => as {
    my ($self, %opts) = @_;
    my $base    = delete $opts{base} || ResultSet;
    my $class   = delete $opts{class};
    my $object  = delete $opts{object_class};
    my $source  = delete $opts{source_class};
    my $action_rules = delete $opts{actions};

    confess('object_class and source_class are required parameters')
      unless $object && $source;
    $class ||= $self->class_name_for_collection_of($object);


    my $package = {
                   name => $class,
                   base => $base,
                   methods => {},
                   method_modifiers => [],
                  };
    {
      my $code = qq^sub { '${object}' }^;
      $package->{methods}->{_build_member_type} = \ $code;
    }

    my %model_action_map;
    {
      my $all_actions = $self->_all_collection_actions;
      my $action_haystack = [keys %$all_actions];
      if(!defined $action_rules){
        $action_rules = $self->default_collection_actions;
      } elsif( (!ref $action_rules && $action_rules) || (ref $action_rules eq 'Regexp') ){
        $action_rules = [ $action_rules ];
      } elsif( ref $action_rules eq 'ARRAY' && @$action_rules){
        #don't add a qr/./ rule if we have at least one match rule
        push(@$action_rules, qr/./)
          unless grep {(ref $_ eq 'ARRAY' && $_->[0] ne '-exclude')
                         || !ref $_  || ref $_ eq 'Regexp'} @$action_rules;
      }

      # XXX this is kind of a dirty hack to support custom actions that are not
      # previously defined and still be able to use the parse_reflect_rules mechanism
      my @custom_actions = grep {!exists $all_actions->{$_}}
        map{ $_->[0] } grep {ref $_ eq 'ARRAY' && $_->[0] ne '-exclude'} @$action_rules;
      push(@$action_haystack, @custom_actions);
      my $actions = $self->parse_reflect_rules($action_rules, $action_haystack);
      for my $action (keys %$actions){
        my $action_opts = $self->merge_hashes
          ($all_actions->{$action} || {}, $actions->{$action} || {});

        #NOTE: If the name of the action is not specified in the prototype then use it's
        #hash key as the name. I think this is sane beahvior, but I've actually been thinking
        #of making Action prototypes their own separate objects
        $self->reflect_source_action(
                                     class        => join('::', $object, 'Action', $action),
                                     name         => $action,
                                     object_class => $object,
                                     source_class => $source,
                                     %$action_opts,
                                    );

        $model_action_map{$action} =  '_source_resultset';
      }
    }
    {
      my $code =  q^ sub {
         my $orig = shift;
         my $tm = $_[0]->_source_resultset;
        ^;

      while(my($act_name, $tm_meth) = each %model_action_map){
        $code .= qq^    \$tm = \$_[0]->$tm_meth if \$_[1] eq '${act_name}';\n^;
      }
      $code .= q^    return { %{ $orig->(@_) }, target_model => $tm }; ^;
      $code .= "\n      }";
      push(
           @{ $package->{method_modifiers} },
           {
            type => 'around',
            name => '_default_action_args_for',
            code => \$code,
           }
          );
    }
    $self->add_to_package($class, $package);
    return $class;
  };

  implements reflect_source_object => as {
    my($self, %opts) = @_;
    %opts = %{ $self->merge_hashes(\%opts, $self->_compute_source_options(%opts)) };

    my $base         = delete $opts{base}  || Object;
    my $class        = delete $opts{class};
    my $dm_name      = delete $opts{domain_model_name};
    my $dm_opts      = delete $opts{domain_model_args} || {};

    my $source_name  = delete $opts{source_name};
    my $schema       = delete $opts{schema_class};
    my $source_class = delete $opts{source_class};
    my $parent       = delete $opts{parent_class};
    my $parent_dm    = delete $opts{parent_domain_model_name};

    my $action_rules = delete $opts{actions};
    my $attr_rules   = delete $opts{attributes};

    $class ||= $self->class_name_from_source_name($parent, $source_name);

    Class::MOP::load_class($parent);
    Class::MOP::load_class($schema) if $schema;
    Class::MOP::load_class($source_class);

    my $package = {
                   name => $class,
                   base => $base,
                   methods => {},
                   method_modifiers => [],
                   domain_models => {},
                  };

    #create the domain model
    $dm_name ||= $self->dm_name_from_source_name($source_name);

    $dm_opts->{isa}        = $source_class;
    $dm_opts->{is}       ||= 'rw';
    $dm_opts->{required} ||= 1;
    $dm_opts->{handles} = {
                           __id => 'id',
                           __ident_condition => 'ident_condition',
                          };
    $dm_opts->{handles}->{display_name} = 'display_name'
      if $source_class->can('display_name');

    $package->{domain_models}{$dm_name} = {%$dm_opts};
    my $dm_reader = $dm_opts->{reader} || $dm_opts->{accessor} || $dm_name;

    {
      my $code = 'sub {
        my $class = shift;
        my ($src) = @_;
        $src = $src->resolve if $src->isa("DBIx::Class::ResultSourceHandle");
        $class->new("'.$dm_name.'", $src->result_class->inflate_result(@_));
      }; ';
      $package->{methods}->{inflate_result} = \$code;
    }

    {
      # attributes => undef,              #default to qr/./
      # attributes => [],                 #default to nothing
      # attributes => qr//,               #DWIM, treated as [qr//]
      # attributes => [{...}]             #DWIM, treat as [qr/./, {...} ]
      # attributes => [[-exclude => ...]] #DWIM, treat as [qr/./, [-exclude => ...]]
      my $attr_haystack =
        [ map { $_->name } $source_class->meta->compute_all_applicable_attributes ];

      if(!defined $attr_rules){
        $attr_rules = [qr/./];
      } elsif( (!ref $attr_rules && $attr_rules) || (ref $attr_rules eq 'Regexp') ){
        $attr_rules = [ $attr_rules ];
      } elsif( ref $attr_rules eq 'ARRAY' && @$attr_rules){
        #don't add a qr/./ rule if we have at least one match rule
        push(@$attr_rules, qr/./) unless
          grep {(ref $_ eq 'ARRAY' && $_->[0] ne '-exclude')
                  || !ref $_  || ref $_ eq 'Regexp'} @$attr_rules;
      }

      my $attributes = $self->parse_reflect_rules($attr_rules, $attr_haystack);
      for my $attr_name (keys %$attributes){
        $self->reflect_source_object_attribute(
                                               class             => $class,
                                               source_class      => $source_class,
                                               parent_class      => $parent,
                                               attribute_name    => $attr_name,
                                               domain_model_name => $dm_name,
                                               %{ $attributes->{$attr_name} || {}},
                                              );
      }
    }

    my %model_action_map;
    {
      my $all_actions = $self->_all_object_actions;
      my $action_haystack = [keys %$all_actions];
      if(!defined $action_rules){
        $action_rules = $self->default_object_actions;
      } elsif( (!ref $action_rules && $action_rules) || (ref $action_rules eq 'Regexp') ){
        $action_rules = [ $action_rules ];
      } elsif( ref $action_rules eq 'ARRAY' && @$action_rules){
        #don't add a qr/./ rule if we have at least one match rule
        push(@$action_rules, qr/./)
          unless grep {(ref $_ eq 'ARRAY' && $_->[0] ne '-exclude')
                         || !ref $_  || ref $_ eq 'Regexp'} @$action_rules;
      }

      # XXX this is kind of a dirty hack to support custom actions that are not
      # previously defined and still be able to use the parse_reflect_rules mechanism
      my @custom_actions = grep {!exists $all_actions->{$_}} map{ $_->[0] }
        grep {ref $_ eq 'ARRAY' && $_->[0] ne '-exclude'} @$action_rules;
      push(@$action_haystack, @custom_actions);
      my $actions = $self->parse_reflect_rules($action_rules, $action_haystack);
      for my $action (keys %$actions){
        my $action_opts = $self->merge_hashes
          ($all_actions->{$action} || {}, $actions->{$action} || {});

        #NOTE: If the name of the action is not specified in the prototype then use it's
        #hash key as the name. I think this is sane beahvior, but I've actually been thinking
        #of making Action prototypes their own separate objects
        $self->reflect_source_action(
                                     class        => join('::', $class, 'Action', $action),
                                     name         => $action,
                                     object_class => $class,
                                     source_class => $source_class,
                                     %$action_opts,
                                    );
        $model_action_map{$action} =  $dm_reader;
      }
    }
    {
      my $code =  qq^ sub {
         my \$orig = shift;
         my \$tm = \$_[0]->${dm_reader};
        ^;

      while(my($act_name, $tm_meth) = each %model_action_map){
        $code .= qq^    \$tm = \$_[0]->${tm_meth} if \$_[1] eq '${act_name}';\n^;
      }
      $code .= q^    return { %{ $orig->(@_) }, target_model => $tm }; ^;
      $code .= "\n      }";
      push(
           @{ $package->{method_modifiers} },
           {
            type => 'around',
            name => '_default_action_args_for',
            code => \$code,
           }
          );
    }
    $self->add_to_package($class, $package);
    return $class;
  };

  # needs class, attribute_name domain_model_name
  implements reflect_source_object_attribute => as {
    my ($self, %opts) = @_;
    unless( $opts{attribute_name} && $opts{class} && $opts{parent_class}
            && ( $opts{source_class} || $opts{domain_model_name} ) ){
      confess( "Error: class, parent_class, attribute_name, and either " .
               "domain_model_name or source_class are required parameters" );
    }

    my $attr_opts = $self->parameters_for_source_object_attribute(%opts);
    $self->add_to_package
      (
       $opts{class},
       { parameter_attributes => { $opts{attribute_name} => {%$attr_opts} } }
      );
  };

  # needs class, attribute_name domain_model_name
  implements parameters_for_source_object_attribute => as {
    my ($self, %opts) = @_;

    my $class        = delete $opts{class};
    my $attr_name    = delete $opts{attribute_name};
    my $dm_name      = delete $opts{domain_model_name};
    my $source_class = delete $opts{source_class};
    my $parent_class = delete $opts{parent_class};
    confess("parent_class is a required argument") unless $parent_class;
    confess("source_class is a required argument") unless $source_class;
    confess("domain_model_name is a required argument") unless $dm_name;

    my $source = $source_class->result_source_instance;
    my $from_attr = $source_class->meta->find_attribute_by_name($attr_name);

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
      my $rel_moniker  = $rel_info->{class}->result_source_instance->source_name;

      if($rel_accessor eq 'multi' && $constraint_is_ArrayRef) {
        #has_many
        my $sm = $self->class_name_from_source_name($parent_class, $rel_moniker);
        #type constraint is a collection, and default builds it
        my $isa = $attr_opts{isa} = $self->class_name_for_collection_of($sm);
        my $code = qq^     sub {
          my \$rs = shift->${dm_name}->related_resultset('${attr_name}');
          return ${isa}->new(_source_resultset => \$rs);
        }^;
        $attr_opts{default} = \$code;
      } elsif( $rel_accessor eq 'single') {
        #belongs_to
        #type constraint is the foreign IM object, default inflates it
        my $isa = $attr_opts{isa} =
          $self->class_name_from_source_name($parent_class, $rel_moniker);
        my $code = qq^     sub {
          shift->${dm_name}->find_related
            (
             '${attr_name}',
             {},
             { result_class => '${isa}' }
            );
        }^;
        $attr_opts{default} = \$code;
      }
    } elsif( $constraint_is_ArrayRef && $attr_name =~ m/^(.*)_list$/ ) {
      #m2m magic
      my $mm_name = $1;
      my $link_table = "links_to_${mm_name}_list";
      my ($hm_source, $far_side);
      eval { $hm_source = $source->related_source($link_table); }
        || confess "Can't find ${link_table} has_many for ${mm_name}_list";
      eval { $far_side = $hm_source->related_source($mm_name); }
        || confess "Can't find ${mm_name} belongs_to on ".$hm_source->result_class
          ." traversing many-many for ${mm_name}_list";

      my $sm = $self->class_name_from_source_name($parent_class,$far_side->source_name);
      my $isa = $attr_opts{isa} = $self->class_name_for_collection_of($sm);

      #proper collections will remove the result_class uglyness.
      my $code = qq^ sub {
        my \$rs = shift->${dm_name}->related_resultset('${link_table}')
          ->related_resultset('${mm_name}');
        return ${isa}->new(_source_resultset => \$rs);
      }^;
      $attr_opts{default} = \$code;

    } else {
      #no rel
      my $reader = $from_attr->get_read_method;
      $attr_opts{isa} = $from_attr->_isa_metadata;
      $attr_opts{default} = \ "sub{ shift->${dm_name}->${reader} }";
    }
    return \%attr_opts;
  };


  implements reflect_source_action => as{
    my($self, %opts) = @_;
    my $name   = delete $opts{name};
    my $class  = delete $opts{class};
    my $base   = delete $opts{base} || Action;
    my $object = delete $opts{object_class};
    my $source = delete $opts{source_class};

    confess("name, class, object_class and source_class are required arguments")
      unless $class && $source && $name && $object;

    my $attr_rules = delete $opts{attributes};
    Class::MOP::load_class( $source );


    #print STDERR "\n\t", ref $attr_rules eq 'ARRAY' ? @$attr_rules : $attr_rules,"\n";
    # attributes => undef,              #default to qr/./
    # attributes => [],                 #default to nothing
    # attributes => qr//,               #DWIM, treated as [qr//]
    # attributes => [{...}]             #DWIM, treat as [qr/./, {...} ]
    # attributes => [[-exclude => ...]] #DWIM, treat as [qr/./, [-exclude => ...]]
    my $attr_haystack =
      [ map { $_ } keys %{ $self->packages->{$object}->{parameter_attributes} }];
    if(!defined $attr_rules){
      $attr_rules = [qr/./];
    } elsif( (!ref $attr_rules && $attr_rules) || (ref $attr_rules eq 'Regexp') ){
      $attr_rules = [ $attr_rules ];
    } elsif( ref $attr_rules eq 'ARRAY' && @$attr_rules){
      #don't add a qr/./ rule if we have at least one match rule
      push(@$attr_rules, qr/./) unless
        grep {(ref $_ eq 'ARRAY' && $_->[0] ne '-exclude')
                || !ref $_  || ref $_ eq 'Regexp'} @$attr_rules;
    }

    #print STDERR "${name}\t${class}\t${base}\n";
    #print STDERR "\t${object}\t${source}\n";
    #print STDERR "\t",@$attr_rules,"\n";

    my $s_meta = $source->meta;
    my $attributes  = $self->parse_reflect_rules($attr_rules, $attr_haystack);

    #create the class
    my $package = {
                   name => $class,
                   superclasses => $base,
                   parameter_attributes => {},
                  };

    my $parent_package = $self->packages->{$object};

    for my $attr_name (keys %$attributes){
      my $attr_opts   = $attributes->{$attr_name} || {};
      my $s_attr_name = $parent_package->{parameter_attributes}
        ->{$attr_name}->{orig_attribute_name} || $attr_name;
      my $s_attr      = $s_meta->find_attribute_by_name($s_attr_name);
      confess("Unable to find attribute for '${s_attr_name}' via '${source}'")
        unless defined $s_attr;
      next unless $s_attr->get_write_method
        && $s_attr->get_write_method !~ /^_/; #only rw attributes!

      my $attr_params = $self->parameters_for_source_object_action_attribute
        (
         object_class   => $object,
         source_class   => $source,
         attribute_name => $attr_name
        );
      $package->{parameter_attributes}->{$attr_name} = { %$attr_params };
    }
  };

  implements parameters_for_source_object_action_attribute => as {
    my ($self, %opts) = @_;

    my $object       = delete $opts{object_class};
    my $attr_name    = delete $opts{attribute_name};
    my $source_class = delete $opts{source_class};
    confess("object_class, $source_class and attribute_name are required parameters")
      unless $attr_name && $object && $source_class;

    my $from_attr = $source_class->meta->find_attribute_by_name($attr_name);

    confess("${attr_name} is not writeable and can not be reflected")
      unless $from_attr->get_write_method;

    my %attr_opts = (
                     is        => 'rw',
                     isa       => $from_attr->_isa_metadata,
                     required  => $from_attr->is_required,
                     ($from_attr->is_required
                       ? () : (clearer => "clear_${attr_name}")),
                     predicate => "has_${attr_name}",
                    );

    if ($attr_opts{required}) {
        if($from_attr->has_default) {
          $attr_opts{lazy} = 1;
          $attr_opts{default} = $from_attr->default;
        } else {
          $attr_opts{lazy_fail} = 1;
        }
    }

    #test for relationships
    my $constraint_is_ArrayRef =
      $from_attr->type_constraint->name eq 'ArrayRef' ||
        $from_attr->type_constraint->is_subtype_of('ArrayRef');

    my $source = $source_class->result_source_instance;
    if (my $rel_info = $source->relationship_info($attr_name)) {
      my $rel_accessor = $rel_info->{attrs}->{accessor};

      if($rel_accessor eq 'multi' && $constraint_is_ArrayRef) {
        confess "${attr_name} is a rw has_many, this won't work.";
      } elsif( $rel_accessor eq 'single') {
        my $code = qq^ sub {
          shift->target_model->result_source
            ->related_source('${attr_name}')->resultset;
        } ^;
        $attr_opts{valid_values} = \ $code;
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

      $attr_opts{default} = \ "sub { [] }";
      my $code = qq^sub {
        shift->target_model->result_source->related_source('${link_table}')
          ->related_source('${mm_name}')->resultset;
      } ^;
    }

    return \%attr_opts;
  };

};

1;

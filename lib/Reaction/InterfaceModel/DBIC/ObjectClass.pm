package Reaction::InterfaceModel::DBIC::ObjectClass;

use Reaction::ClassExporter;
use Reaction::Class;
use aliased 'Reaction::InterfaceModel::DBIC::Collection';
use Class::MOP;

use aliased 'Reaction::InterfaceModel::Action::DBIC::ResultSet::Create';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Update';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Delete';

use aliased 'Reaction::Meta::InterfaceModel::Action::Class' => 'ActionClass';

class ObjectClass, is 'Reaction::InterfaceModel::ObjectClass', which {
  override exports_for_package => sub {
    my ($self, $package) = @_;
    my %exports = $self->SUPER::exports_for_package($package);

    $exports{reflect_actions} = sub {

      my %actions = @_;
      my $meta = $package->meta;
      my $defaults = {
                      'Create' => { base => Create },
                      'Update' => { base => Update },
                      'Delete' => { base => Delete },
                     };

      while (my($name,$opts) = each %actions) {
        my $action_class = delete $opts->{class} ||
          $package->_default_action_class_for($name);

        #support this for now, I don't know about defaults yet though.
        #especially, '*' for all writtable attributes. ugh
        my $super = delete $opts->{base} || $defaults->{$name}->{base} || [];
        my $attrs = delete $opts->{attrs} || [];
        $super = (ref($super) ne 'ARRAY' && $super) ? [ $super ] : [];

        $self->reflect_action($meta, $action_class, $super, $attrs);
      }
    };


    my $orig_domain_model = delete $exports{domain_model};
    $exports{domain_model} = sub {
      my($dm_name, %opts) = @_;

      my $reflect = delete $opts{reflect};
      my $inflate_result = delete $opts{inflate_result};

      my @attr_names = map {ref $_ ? $_->[0] : $_ } @$reflect;
      $opts{reflect} = [@attr_names];
      $orig_domain_model->($dm_name, %opts);

      #Create an inflate result_method for DBIC objects
      my $meta = $package->meta;
      if ($inflate_result) {
        my $inflate = sub {
          my $class = shift; my ($source) = @_;
          if($source->isa('DBIx::Class::ResultSourceHandle'))
          {
              $source = $source->resolve;
          }
          return $class->new
            ($dm_name, $source->result_class->inflate_result(@_));
        };
        $meta->add_method('inflate_result', $inflate);
      }

      #relationship magic
      my %rel_attrs = map{ @$_ } grep {ref $_} @$reflect;
      my $dm_meta = $opts{isa}->meta;

      for my $attr_name ( @attr_names ) {

        my $from_attr = $dm_meta->find_attribute_by_name($attr_name);
        confess "Failed to get attribute $attr_name from class $opts{isa}"
          unless $from_attr;

        if ( my $info = $opts{isa}->result_source_instance
             ->relationship_info($attr_name) ) {

          next unless(my $rel_accessor = $info->{attrs}->{accessor});

          unless ( $rel_attrs{$attr_name} ) {
            my ($im_class) = ($package =~ /^(.*)::\w+$/);
            my ($rel_class) = ($attr_name =~ /^(.*?)(_list)?$/);
            $rel_class = join '', map{ ucfirst($_) } split '_', $rel_class;
            $rel_attrs{$attr_name} = "${im_class}::${rel_class}";
          }
          Class::MOP::load_class($rel_attrs{$attr_name}) ||
              confess "Could not load ".$rel_attrs{$attr_name};

          #has_many rels
          if ($rel_accessor eq 'multi' &&
              ( $from_attr->type_constraint->name eq 'ArrayRef' ||
                $from_attr->type_constraint->is_subtype_of('ArrayRef') )
             ) {

            # # remove the old attribute and recreate it with new isa
            my %attr_opts = ( is => 'ro',
                              lazy_build => 1,
                              isa => Collection,
                              clearer => "_clear_${attr_name}",
                              domain_model => $dm_name,
                              orig_attr_name => $attr_name,
                            );
            $meta->add_attribute( $attr_name, %attr_opts);

            #remove old build and add a better one
            #proper collections will remove the result_class uglyness.
            my $build_method = sub {
              my $rs = shift->$dm_name->search_related_rs
                ($attr_name, {},
                 {
                  result_class => $rel_attrs{$attr_name} });
              return bless($rs => Collection);
            };
            $meta->remove_method( "build_${attr_name}");
            $meta->add_method( "build_${attr_name}", $build_method);
          } elsif ($rel_accessor eq 'single') {
            # # remove the old attribute and recreate it with new isa
            my %attr_opts = ( is => 'ro',
                              lazy_build => 1,
                              isa => $rel_attrs{$attr_name},
                              clearer => "_clear_${attr_name}",
                              domain_model => $dm_name,
                              orig_attr_name => $attr_name,
                            );
            $meta->add_attribute( $attr_name, %attr_opts);

            #delete and recreate the build method to properly inflate the
            #result into an IM::O class instead of the original
            #this probably needs some cleaning
            #proper collections will remove the result_class uglyness.
            my $build_method = sub {
              shift->$dm_name->find_related
                ($attr_name, {},
                 {
                  result_class => $rel_attrs{$attr_name}});
            };
            $meta->remove_method( "build_${attr_name}");
            $meta->add_method( "build_${attr_name}", $build_method);
          }
        } elsif ( $from_attr->type_constraint->name eq 'ArrayRef' ||
                  $from_attr->type_constraint->is_subtype_of('ArrayRef')
                ) {
          #m2m magicness
          next unless $attr_name =~ m/^(.*)_list$/;
          my $mm_name = $1;
          my ($hm_source, $far_side);
          # we already get one for the rel info check, unify that??
          my $source = $opts{isa}->result_source_instance;
          eval { $hm_source = $source->related_source("links_to_${mm_name}_list"); }
            || confess "Can't find links_to_${mm_name}_list has_many for ${mm_name}_list";
          eval { $far_side = $hm_source->related_source($mm_name); }
            || confess "Can't find ${mm_name} belongs_to on ".$hm_source->result_class
              ." traversing many-many for ${mm_name}_list";

          # # remove the old attribute and recreate it with new isa
          my %attr_opts = ( is => 'ro',
                            lazy_build => 1,
                            isa => Collection,
                            clearer => "_clear_${attr_name}",
                            domain_model => $dm_name,
                            orig_attr_name => $attr_name,
                          );
          $meta->add_attribute( $attr_name, %attr_opts);

          #proper collections will remove the result_class uglyness.
          my $build_method = sub {
            my $rs = shift->$dm_name->result_source
              ->related_source("links_to_${mm_name}_list")
                ->related_source(${mm_name})
                  ->resultset->search_rs
                    ({},{result_class => $rel_attrs{$attr_name} });
            return bless($rs => Collection);
          };
          $meta->remove_method( "build_${attr_name}");
          $meta->add_method( "build_${attr_name}", $build_method);
        }
      }
    };
    return %exports;
  };
};


sub reflect_action{
  my($self, $meta, $action_class, $super, $attrs) = @_;

  Class::MOP::load_class($_) for @$super;

  #create the class
  my $ok = eval { Class::MOP::load_class($action_class) };

  confess("Class '${action_class}' does not seem to support method 'meta'")
    if $ok && !$action_class->can('meta');

  my $action_meta = $ok ?
    $action_class->meta : ActionClass->create($action_class, superclasses => $super);

  $action_meta->make_mutable if $action_meta->is_immutable;

  foreach my $attr_name (@$attrs){
    my $attr = $meta->find_attribute_by_name($attr_name);
    my $dm_isa = $meta->find_attribute_by_name($attr->domain_model)->_isa_metadata;
    my $from_attr = $dm_isa->meta->find_attribute_by_name($attr->orig_attr_name);

    #Don't reflect read-only attributes to actions
    if ($from_attr->_is_metadata ne 'rw') {
      warn("Not relecting read-only attribute ${attr_name} to ${action_class}");
      next;
    }

    #add the attribute to the class
    $action_class->meta->add_attribute
      ( $attr_name =>
        $self->reflected_attr_opts($meta, $dm_isa, $from_attr)
      );
  }

  $action_class->meta->make_immutable;
}

sub reflected_attr_opts{
  my ($self, $meta, $dm, $attr) = @_;
  my $attr_name = $attr->name;

  my %opts = (
              is        => 'rw',
              isa       => $attr->_isa_metadata,
              required  => $attr->is_required,
              predicate => "has_${attr_name}",
             );

  if ($opts{required}) {
    $opts{default} = !$attr->has_default ?
      sub{confess("${attr_name} must be provided before calling reader")}
        : $attr->default;
    $opts{lazy} = 1;
  }

  #test for relationships
  my $source = $dm->result_source_instance;
  my $constraint = $attr->type_constraint;
  if (my $info = $source->relationship_info($attr_name)) {
    if ( $info->{attrs}->{accessor} &&
         $info->{attrs}->{accessor} eq 'multi') {
      confess "${attr_name} is multi and rw. we are confoos.";
    } else {
      $opts{valid_values} = sub {
        $_[0]->target_model->result_source
          ->related_source($attr_name)->resultset;
      };
    }
  } elsif ($constraint->name eq 'ArrayRef' ||
           $constraint->is_subtype_of('ArrayRef')) {
    # it's a many-many. time for some magic.
    my $link_rel = "links_to_${attr_name}";
    my ($mm_name) = ($attr_name =~ m/^(.*)_list$/);
    confess "Many-many attr must be called <name>_list for reflection"
      unless $mm_name;

    my ($hm_source, $far_side);
    eval { $hm_source = $source->related_source($link_rel); }
      || confess "Can't find ${link_rel} has_many for ${attr_name}";
    eval { $far_side = $hm_source->related_source($mm_name); }
      || confess "Can't find ${mm_name} belongs_to on " .
        $hm_source->result_class." traversing many-many for ${attr_name}";

    $opts{default} = sub { [] };
    $opts{valid_values} = sub {
      $_[0]->target_model->result_source->related_source($link_rel)
        ->related_source($mm_name)->resultset;
    };
  }

  return \%opts;
}

1;

=head1 NAME

Reaction::InterfaceModel::DBIC::ObjectClass

=head1 SYNOPSIS

=head2 domain_model

    package Prefab::AdminModel::User;

    class User, is Object, which{
        #create an attribute _user_store with type constraint MyApp::DB::User
        domain_model '_user_store' =>
            (isa => 'MyApp::DB::User',
             #mirror the following attributes from MyApp::DB::User
             #will create collections for rels which use result_classes of:
             # Prefab::AdminModel::(Group|ImagedDocument)
             # Prefab::AdminModel::DocumentNotes
             reflect => [qw/id username password created_d group_list imaged_document/,
                         [doc_notes_list => 'Prefab::AdminModel::DocumentNotes']
                        ],
             #automatically add a sub inflate_result that inflates the DBIC obj
             #to a Prefab::AdminModel::User with the dbic obj in _user_store
             inflate_result => 1,
            );
    };

=head2 reflect_actions

  reflect_actions
    (
     Create => { attrs =>[qw(first_name last_name baz_list)] },
     Update => { attrs =>[qw(first_name last_name baz_list)] },
     Delete => {},
    );

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 isa

=head2 reflect

=head2 inflate_result

=head2 handles

=head1 METHODS

=head2 reflect_actions

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::InterfaceModel::ObjectClass;

use Reaction::ClassExporter;
use Reaction::Class;
use Class::MOP;

#use Reaction::InterfaceModel::Object;
use Moose::Util::TypeConstraints ();
use Reaction::InterfaceModel::Object;

class ObjectClass which {

  overrides default_base => sub { ('Reaction::InterfaceModel::Object') };

  overrides exports_for_package => sub {
    my ($self, $package) = @_;
    my %exports = $self->SUPER::exports_for_package($package);

    $exports{domain_model} = sub {
      my($dm_name, %opts)= @_;

      my $isa = $opts{isa};
      confess 'no isa declared!' unless defined $isa;

      unless( ref $isa || Moose::Util::TypeConstraints::find_type_constraint($isa) ){
        eval{ Class::MOP::load_class($isa) };
        warn "'${isa}' is not a valid Moose type constraint. Moose will treat it as ".
          "a class name and create an anonymous constraint for you. This class is ".
            "not currently load it and ObjectClass failed to load it. ($@)"
              if $@;
      }

      my $attrs = delete $opts{reflect};
      my $meta = $package->meta;

      #let opts override is and required as needed
      my $dm_attr = $meta->add_domain_model($dm_name, is => 'ro', required => 1, %opts);

      return unless ref $attrs && @$attrs;
      my $dm_meta = eval{ $isa->meta };
      confess "Reflection requires that the argument to isa ('${isa}') be a class ".
        " supporting introspection e.g a Moose-based class." if $@;

      foreach my $attr_name (@$attrs) {
        my $from_attr = $dm_meta->find_attribute_by_name($attr_name);
        my $reader = $from_attr->get_read_method;

        my %attr_opts = ( is => 'ro',
                          lazy_build => 1,
                          isa => $from_attr->_isa_metadata,
                          clearer => "_clear_${attr_name}",
                          domain_model => $dm_name,
                          orig_attr_name => $attr_name,
                        );

        $meta->add_attribute( $attr_name, %attr_opts);
        $meta->add_method( "build_${attr_name}", sub{ shift->$dm_name->$reader });
      }

      my $clearer = sub{ $_[0]->$_ for map { "_clear_${_}" } @$attrs };

      $package->can('_clear_reflected') ?
        $meta->add_before_method_modifier('_clear_reflected', $clearer) :
          $meta->add_method('_clear_reflected', $clearer);

      #i dont like this, this needs reworking, maybe pass
      #  target_models => [$self->meta->domain_models?]
      # or maybe this should be done by reflect_actions ?
      # what about non-reflected actions then though?
      # maybe a has_action => ('Action_Name' => ActionClass) keyword?
      #it'd help in registering action_for ....
      #UPDATE: this is going away very very soon
      my $dm_reader = $dm_attr->get_read_method;
      if($package->can('_default_action_args_for')){
        my $act_args =  sub {
          my $super = shift;
          my $self = shift;
          return { %{ $super->($self, @_) }, target_model => $self->$dm_reader };
        };
        $meta->add_around_method_modifier('_default_action_args_for', $act_args);
      } else {
        $meta->add_method('_default_action_args_for', sub {
                            return {target_model => shift->$dm_reader};
                          }
                         );
      }
    };

    return %exports;
  };

};

1;

__END__;

=head1 NAME

Reaction::Class::InterfaceModel::ObjectClass

=head1 SYNOPSIS

    package MyApp::AdminModel::Foo;
    use Reaction::Class::InterfaceModel::ObjectClass;

    #will default to be a Reaction::InterfaceModel::Object unless otherwise specified
    class Foo, which{
        #create an attribute _user_store with type constraint MyApp::Data::User
        domain_model '_user_store' =>
            (isa => 'MyApp::Data::User',
             #mirror the following attributes from MyApp::Data::User
             reflect => [qw/id username password created_d/],
             ...
    };

=head1 DESCRIPTION

Extends C<Reaction::Class> to provide new sugar for InterfaceModel Objects.

=head1 Extended methods / new functionality

=head2 exports_for_package

Overridden to add exported methods C<proxies> and C<_clear_proxied>

=head2 domain_model $name => ( isa => 'Classname' reflect => [qw/attr names/] )

Will create a read-only required  attribute $name of type C<isa> which will
reflect the attributes named in C<reflect>,  to the local class as
read-only attributes that will build lazily.

It will also override C<_default_action_args_for> to pass the domain model
as C<target_model>

=head2 _clear_reflected

Will clear all reflected attributes.

=head2 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

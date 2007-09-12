package Reaction::InterfaceModel::DBIC::SchemaClass;

use Reaction::ClassExporter;
use Reaction::Class;
use aliased 'Reaction::InterfaceModel::DBIC::Collection';
use Reaction::InterfaceModel::Object;
use Class::MOP;

# consider that the schema class should provide it's own connect method, that
# way for single domain_models we could just let handles => take care of it
# and for many domain_models we could iterate through them and connect.. or something
# similar. is that crossing layers?? I think it seems reasonable TBH

class SchemaClass which {

  overrides default_base => sub { ('Reaction::InterfaceModel::Object') };

  override exports_for_package => sub {
    my ($self, $package) = @_;
    my %exports = $self->SUPER::exports_for_package($package);

    $exports{domain_model} = sub{
      my($dm_name, %opts) = @_;
      my $meta = $package->meta;

      my $isa = $opts{isa};
      confess 'no isa declared!' unless defined $isa;

      unless( ref $isa || Moose::Util::TypeConstraints::find_type_constraint($isa) ){
        eval{ Class::MOP::load_class($isa) };
        warn "'${isa}' is not a valid Moose type constraint. Moose will treat it as ".
          "a class name and create an anonymous constraint for you. This class is ".
            "not currently load it and ObjectClass failed to load it. ($@)"
              if $@;
      }

      my $reflect = delete $opts{reflect};
      confess("parameter 'reflect' must be an array reference")
        unless ref $reflect eq 'ARRAY';

      $meta->add_domain_model($dm_name, is => 'ro', required => 1, %opts);

      for ( @$reflect ){
        my ($moniker,$im_class,$reader) = ref $_ eq 'ARRAY' ? @$_ : ($_);

        my $clearer = "_clear_${moniker}";
        $im_class ||= "${package}::${moniker}";
        Class::MOP::load_class($im_class) || confess "Could not load ${im_class}";

        unless($reader){
          $reader = $moniker;
          $reader =~ s/([a-z0-9])([A-Z])/${1}_${2}/g ;
          $reader = lc($moniker) . "_collection";
        }
        # problem: we should have fresh resultsets every time the reader is called
        # solution 1: override reader to return fresh resultsets each time.
        # solution 2: uing an around modifier on the reader,call clearer after
        # getting the collection from the $super->(), but before returning it.
        #  #1 seems more efficient, but #2 seems more correct.
        my %args = (isa => Collection, domain_model => $dm_name,
                    lazy_build => 1, reader => $reader, clearer => $clearer);
        my $attr = $meta->add_attribute($moniker, %args);

        # blessing into a collection is very dirty, but it'll have to do until I
        # create a proper collection object. This should happen as soon as me and mst
        # can deisgn a common API for Collections.
        my $build_method = sub {
          my $collection = shift->$dm_name->resultset( $moniker );
          $collection = $collection->search_rs({}, {result_class => $im_class});
          return bless($collection => Collection);
        };

        $meta->add_method( "build_${moniker}", $build_method);

        my $reader_method = sub{
          my ($super, $self) = @_;
          my $result = $super->($self);
          $self->$clearer;
          return $result;
        };
        $meta->add_around_method_modifier($attr->reader, $reader_method);
      }
    };

    return %exports;
  };
};

1;

__END__;

=head1 NAME

Reaction::InterfaceModel::DBIC::SchemaClass

=head1 SYNOPSYS

  package MyApp::AdminModel;

  use Reaction::InterfaceModel::DBIC::ObjectClass;

  #unless specified, the superclass will be Reaction::InterfaceModel::Object
  class AdminModel, which{
    domain_model'my_db_schema' =>
    ( isa => 'MyApp::Schema',
      reflect => [
                  'ResultSetA', # same as ['ResultSetA']
                  [ResultSetB => 'MyApp::AdminModel::RSB'],
                  [ResultSetC => 'MyApp::AdminModel::RSC', 'resultset_c_collection'],
                 ],
    );

=head1 DESCRIPTION

Each item in reflect may be either a string or an arrayref. If a string, it should be
the name of the ResultSet, ie what you would put inside
  $schema->resultset( 'rs_name' ); As an array it must contain the resultset name,
and may optionally provide the proper InterfaceModel class and the name of the method
used to obtain a collection.

The example shown will generate reflects 3 resultsets from MyApp::Schema,
a DBIC::Schema file which will be stored as attribute 'my_db_schema', which is
an attribute of type Reaction::InterfaceModel::Object::DomainModelAttribute.

ResultSetA will be reflected as an attribute named 'ResultSetA', will inflate to the
IM Class 'MyApp::AdminModel::ResultSetA' and a collection can be obtained through
MyApp::AdminModel->resultseta_collection

ResultSetB will be reflected as an attribute named 'ResultSetB', will inflate to the
IM Class 'MyApp::AdminModel::RSB' and a collection can be obtained through
MyApp::AdminModel->resultsetb_collection

ResultSetC will be reflected as an attribute named 'ResultSetC', will inflate to the
IM Class 'MyApp::AdminModel::RSC' and a collection can be obtained through
MyApp::AdminModel->resultset_c_collection

=head1 METHODS

=head2 default_base

Specifies the superclass, the default being L<Reaction::InterfaceModel::Object>.

=head2 exports_for_package

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

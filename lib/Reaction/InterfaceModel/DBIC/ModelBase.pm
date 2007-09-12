package Reaction::InterfaceModel::DBIC::ModelBase;

use Reaction::Class;

use Catalyst::Utils;
use Catalyst::Component;
use Class::MOP;

class ModelBase, is 'Reaction::Object', is 'Catalyst::Component', which {

  has '_schema' => (isa => 'DBIx::Class::Schema', is => 'ro', required => 1);

  implements 'COMPONENT' => as {
    my ($class, $app, $args) = @_;
    my %cfg = %{ Catalyst::Utils::merge_hashes($class->config, $args) };

    my $im_class = $cfg{im_class};
    Class::MOP::load_class($im_class);

    my $model_name = $class;
    $model_name =~ s/^[\w:]+::(?:Model|M):://;

    #this could be cut out later for a more elegant method
    my @domain_models = $im_class->domain_models;
    confess "Unable to locate domain model in ${im_class}"
      if @domain_models < 1;
    confess 'ModelBase does not yet support multiple domain models'
      if @domain_models > 1;
    my $domain_model = shift @domain_models;
    my $schema_class = $domain_model->_isa_metadata;
    Class::MOP::load_class($schema_class);

    {
      #I should probably MOPize this at some point maybe? nahhhh
      no strict 'refs';
      foreach my $collection ( $im_class->parameter_attributes ){
        my $classname = join '::', $class, $collection->name, 'ACCEPT_CONTEXT';
        my $reader  = $collection->get_read_method;
        *$classname = sub{ $_[1]->model($model_name)->$reader };
      }
    }

    my $params = $cfg{db_params} || {};
    my $schema = $schema_class
      ->connect($cfg{db_dsn}, $cfg{db_user}, $cfg{db_password}, $params);

    return $class->new(_schema => $schema);
  };

  implements 'ACCEPT_CONTEXT' => as {
    my ($self, $ctx) = @_;
    return $self->CONTEXTUAL_CLONE($ctx) unless ref $ctx;
    return $ctx->stash->{ref($self)} ||= $self->CONTEXTUAL_CLONE($ctx);
  };

  #to do build in support for RestrictByUser natively or by subclass
  implements 'CONTEXTUAL_CLONE' => as {
    my ($self, $ctx) = @_;
    my $schema = $self->_schema->clone;

    my $im_class = $self->config->{im_class};

    #this could be cut out later for a more elegant method
    my @domain_models = $im_class->domain_models;
    confess "Unable to locate domain model in ${im_class}"
      if @domain_models < 1;
    confess 'ModelBase does not yet support multiple domain models'
      if @domain_models > 1;
    my $domain_model = shift @domain_models;

    return $im_class->new($domain_model->name => $schema);
  };

};


1;

=head1 NAME

Reaction::InterfaceModel::DBIC::ModelBase

=head1 DESCRIPTION

=head2 COMPONENT

=head2 ACCEPT_CONTEXT

=head2 CONTEXTUAL_CLONE

=head1 CONFIG OPTIONS

=head2 db_dsn

=head2 db_user

=head2 db_password

=head2 db_params

=head2 im_class

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

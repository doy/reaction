package Reaction::InterfaceModel::Collection::DBIC::Role::Base;

use Reaction::Role;
use Scalar::Util qw/blessed/;
use Class::MOP;

# WARNING - DANGER: this is just an RFC, please DO NOT USE YET

role Base, which {

  has '_source_resultset' => (
                             is => 'ro',
                             required => 1,
                             isa => 'DBIx::Class::ResultSet',
                            );

  has '_im_class' => (
                      is         => 'ro',
                      isa        => 'Str',
                      lazy_build => 1,
                     );

  #implements BUILD => as {
  #  my $self = shift;
  #  Class::MOP::load_class($self->_im_class);
  #  confess "_im_result_class must be a Reaction::InterfaceModel::Object"
  #    unless $self->_im_class->isa("Reaction::InterfaceModel::Object");
  #  confess "_im_result_class must have an inflate_result method"
  #    unless $self->_im_class->can("inflate_result");
  #};

  #Oh man. I have a bad feeling about this one.
  implements _build__im_class => as {
    my $self = shift;
    my $class = blessed($self) || $self;
    $class =~ s/::Collection$//;
    return $class;
  };

  implements _build__collection_store => as {
    my $self = shift;
    my $im_class = $self->_im_class;
    [ $self->_source_resultset->search({}, {result_class => $im_class})->all ];
  };

  implements clone => as {
    my $self = shift;
    my $rs = $self->_source_resultset->search_rs({});
    #should the clone include the arrayref of IM::Objects too?
    return (blessed $self)->new(
                                _source_resultset => $rs,
                                _im_class => $self->_im_class, @_
                               );
  };

  implements count_members => as {
    my $self = shift;
    $self->_source_resultset->count;
  };

  implements add_member => as {
    confess "Not yet implemented";
  };

  implements remove_member => as {
    confess "Not yet implemented";
  };


  implements page => as {
    my $self = shift;
    my $rs = $self->_source_resultset->page(@_);
    return (blessed $self)->new(
                                _source_resultset => $rs,
                                _im_class => $self->_im_class,
                               );
  };

  implements pager => as {
    my $self = shift;
    return $self->_source_resultset->pager(@_);
  };

};

1;


=head1 NAME

Reaction::InterfaceModel::Collection::DBIC::Role::Base

=head1 DESCRIPTION

Provides methods to allow a collection to be populated by a L<DBIx::Class::ResultSet>

=head1 Attributes

=head2 _source_resultset

Required, Read-only. Contains the L<DBIx::Class::ResultSet> used to populate the
collection.

=head2 _im_class

Read-only, lazy_build. The name of the IM Object Class that the resultset inside this
collection will inflate to. Predicate: C<_has_im_class>

=head1 METHODS

=head2 clone

Returns a clone of the current collection, complete with a cloned C<_source_resultset>

=head2 count_members

Returns the number of items found by the ResultSet

=head2 add_member

=head2 remove_member

These will die as they have not been implemented yet.

=head1 PRIVATE METHODS

=head2 _build_im_class

Will attempt to remove the suffix "Collection" from the current class name and return
that. I.e. C<MyApp::MyIM::Roles::Collection> would return C<MyApp::MyIM::Roles>

=head2 _build_collection_store

Replace the default builder to populate the collection with all results returned by the
resultset.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

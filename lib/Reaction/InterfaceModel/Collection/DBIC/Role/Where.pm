package Reaction::InterfaceModel::Collection::DBIC::Role::Where;

use Reaction::Role;
use Scalar::Util qw/blessed/;

role Where, which {

  #requires qw/_source_resultset _im_class/;

  implements where => as {
    my $self = shift;
    my $rs = $self->_source_resultset->search_rs(@_);
    return (blessed $self)->new(
                                _source_resultset => $rs,
                                _im_class => $self->_im_class
                               );
  };

  implements add_where => as {
    my $self = shift;
    my $rs = $self->_source_resultset->search_rs(@_);
    $self->_source_resultset($rs);
    $self->_clear_collection_store if $self->_has_collection_store;
    return $self;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Collection::DBIC::Role::Where

=head1 DESCRIPTION

Provides methods to allow a ResultSet collection to be restricted

=head1 METHODS

=head2 where

Will return a clone with a restricted C<_source_resultset>.

=head2 add_where

Will return itself after restricting C<_source_resultset>. This also clears the
C<_collection_store>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

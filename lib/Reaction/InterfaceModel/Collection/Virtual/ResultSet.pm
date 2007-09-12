package Reaction::InterfaceModel::Collection::Virtual::ResultSet;

use Reaction::Class;
# WARNING - DANGER: this is just an RFC, please DO NOT USE YET

class ResultSet is "Reaction::InterfaceModel::Collection::Virtual", which {

  does "Reaction::InterfaceModel::Collection::DBIC::Role::Base",
       "Reaction::InterfaceModel::Collection::DBIC::Role::Where";


  implements _build_default_action_class_prefix => as {
    shift->_im_class;
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Collection::Virtual::ResultSet

=head1 DESCRIPTION

A virtual collection powered by a resultset

=head1 METHODS

=head2 _build_default_action_class_prefix

Returns the classname of the interface model objects contained in this collection.

=head1 ROLES CONSUMED

The following roles are consumed by this class, for more information about the
methods and attributes provided by them please see their respective documentation.

=over 4

=item L<Reaction::InterfaceModel::Collection::DBIC::Role::Base>

=item L<Reaction::InterfaceModel::Collection::DBIC::Role::Where>

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

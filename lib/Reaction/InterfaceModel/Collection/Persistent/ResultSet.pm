package Reaction::InterfaceModel::Collection::Persistent::ResultSet;

use Reaction::Class;

# WARNING - DANGER: this is just an RFC, please DO NOT USE YET

class ResultSet is "Reaction::InterfaceModel::Collection::Persistent", which{

  does "Reaction::InterfaceModel::Collection::DBIC::Role::Base";

};

1;

=head1 NAME

Reaction::InterfaceModel::Collection::Persistent::ResultSet

=head1 DESCRIPTION

A persistent collection powered by a resultset

=head1 ROLES CONSUMED

The following roles are consumed by this class, for more information about the
methods and attributes provided by them please see their respective documentation.

=over 4

=item L<Reaction::InterfaceModel::Collection::DBIC::Role::Base>

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

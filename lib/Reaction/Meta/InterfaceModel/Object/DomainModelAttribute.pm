package Reaction::Meta::InterfaceModel::Object::DomainModelAttribute;

use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::Meta::Attribute';


#i feel like something should happen here, but i aint got nothin.
sub new { shift->SUPER::new(@_); }; # work around immutable

__PACKAGE__->meta->make_immutable;


1;

=head1 NAME

Reaction::Meta::InterfaceModel::Action::DomainModelAttribute

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

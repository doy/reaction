package Reaction::Meta::InterfaceModel::Object::DomainModelAttribute;

use Reaction::Class;

class DomainModelAttribute is 'Reaction::Meta::Attribute', which {
  #i feel like something should happen here, but i aint got nothin.

  implements new => as { shift->SUPER::new(@_); }; # work around immutable

};

1;

=head1 NAME

Reaction::Meta::InterfaceModel::Action::DomainModelAttribute

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

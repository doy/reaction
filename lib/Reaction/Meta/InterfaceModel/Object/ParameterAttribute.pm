package Reaction::Meta::InterfaceModel::Object::ParameterAttribute;

use Reaction::Class;

class ParameterAttribute is 'Reaction::Meta::Attribute', which {
  has domain_model => (
    isa => 'Str',
    is => 'ro',
    predicate => 'has_domain_model'
  );

  has orig_attr_name => (
    isa => 'Str',
    is => 'ro',
    predicate => 'has_orig_attr_name'
  );

  implements new => as { shift->SUPER::new(@_); }; # work around immutable
};

1;

=head1 NAME

Reaction::Meta::InterfaceModel::Object::ParameterAttribute

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 domain_model

=head2 orig_attr_name

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

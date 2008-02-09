package Reaction::Meta::InterfaceModel::Action::Class;

use Reaction::Class;
use aliased 'Reaction::Meta::InterfaceModel::Action::ParameterAttribute';

class Class is 'Reaction::Meta::Class', which {

  implements new => as { shift->SUPER::new(@_) };

  around initialize => sub {
    my $super = shift;
    my $class = shift;
    my $pkg   = shift;
    $super->($class, $pkg, attribute_metaclass => ParameterAttribute, @_);
  };

  implements parameter_attributes => as {
    my $self = shift;
    return grep { $_->isa(ParameterAttribute) } 
      $self->compute_all_applicable_attributes;
  };

};
  
1;

=head1 NAME

Reaction::Meta::InterfaceModel::Action::Class

=head1 DESCRIPTION

=head2 parameter_attributes

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

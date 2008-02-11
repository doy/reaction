package Reaction::Meta::InterfaceModel::Object::Class;

use aliased 'Reaction::Meta::InterfaceModel::Object::ParameterAttribute';
use aliased 'Reaction::Meta::InterfaceModel::Object::DomainModelAttribute';

use Reaction::Class;

class Class is 'Reaction::Meta::Class', which {

  implements new => as { shift->SUPER::new(@_) };

  around initialize => sub {
    my $super = shift;
    my $class = shift;
    my $pkg   = shift;
    $super->($class, $pkg, attribute_metaclass => ParameterAttribute, @_);
  };

  implements add_domain_model => as{
    my $self = shift;
    my $name = shift;
    $self->add_attribute($name, metaclass => DomainModelAttribute, @_);
  };

  implements parameter_attributes => as {
    my $self = shift;
    return grep { $_->isa(ParameterAttribute) } 
      $self->compute_all_applicable_attributes;
  };

  implements domain_models => as {
    my $self = shift;
    return grep { $_->isa(DomainModelAttribute) } 
      $self->compute_all_applicable_attributes;
  };

};
  
1;

=head1 NAME

Reaction::Meta::InterfaceModel::Object::Class

=head1 DESCRIPTION

=head1 METHODS

=head2 add_domain_model

=head2 domain_models

=head2 parameter_attributes

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

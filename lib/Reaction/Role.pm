package Reaction::Role;

use Moose::Role ();
use Reaction::ClassExporter;
use Reaction::Class;
use Moose::Meta::Class;

use Sub::Name 'subname';
use Scalar::Util qw/blessed reftype/;

#TODO: review for Reaction::Object switch / Reaction::Meta::Class
#lifted from class MOP as a temp fix (groditi)
*Moose::Meta::Role::add_method
  = subname 'Moose::Meta::Role::add_method' => sub {
    my ($self, $method_name, $code) = @_;
    (defined $method_name && $method_name)
      || confess "You must define a method name";

    confess "Your code block must be a CODE reference"
      unless 'CODE' eq reftype($code);

    my $method = $self->method_metaclass->wrap($code);
    $self->get_method_map->{$method_name} = $method;

    my $full_name = ($self->name . '::' . $method_name);
    $self->add_package_symbol("&${method_name}" => subname $full_name => $code);
  };


class Role which {

  override exports_for_package => sub {
    my ($self, $package) = @_;
    my %exports = $self->SUPER::exports_for_package($package);
    delete $exports{class};
    $exports{role} = sub { $self->do_role_sub($package, @_); };
    return %exports;
  };

  override next_import_package => sub { 'Moose::Role' };

  override default_base => sub { () };

  implements do_role_sub => as {
    my ($self, $package, $role, $which, $setup) = @_;
    confess "Invalid role declaration, should be: role Role which { ... }"
      unless ($which eq 'which' && ref($setup) eq 'CODE');
    $self->setup_and_cleanup($role, $setup);
  };

};

1;

=head1 NAME

Reaction::Role

=head1 DESCRIPTION

=head1 SEE ALSO

L<Moose::Role>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

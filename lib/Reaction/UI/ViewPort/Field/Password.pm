package Reaction::UI::ViewPort::Field::Password;

use Reaction::Class;

class Password is 'Reaction::UI::ViewPort::Field::String', which {

  has '+value' => (isa => 'SimpleStr');
  has '+layout' => (default => 'password');

};

1;  

=head1 NAME

Reaction::UI::ViewPort::Field::Password

=head1 DESCRIPTION

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

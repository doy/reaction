package Reaction::UI::ViewPort::Field::Text;

use Reaction::Class;

class Text is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => 'Str');
  #has '+layout' => (default => 'textarea');

};

1;

=head1 NAME

Reaction::UI::ViewPort::Field::Text

=head1 DESCRIPTION

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

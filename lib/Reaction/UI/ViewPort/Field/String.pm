package Reaction::UI::ViewPort::Field::String;

use Reaction::Class;

class String is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => 'Str'); # accept over 255 chars in case, upstream
                                  # constraint from model should catch it

  #has '+layout' => (default => 'textfield');

};

1;

=head1 NAME

Reaction::UI::ViewPort::Field::String

=head1 DESCRIPTION

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

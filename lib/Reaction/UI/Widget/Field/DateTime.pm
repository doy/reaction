package Reaction::UI::Widget::Field::DateTime;

use Reaction::UI::WidgetClass;

class DateTime is 'Reaction::UI::Widget::Field', which {

  fragment field [ string { $_{viewport}->value_string }, ];

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::DateTime

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 FRAGMENTS

=head2 field

C<content> contains viewport's C<value_string>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

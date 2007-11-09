package Reaction::UI::Widget::DisplayField::DateTime;

use Reaction::UI::WidgetClass;

class DateTime is 'Reaction::UI::Widget::DisplayField', which {
  fragment value [ string { $_{viewport}->value_string } ];
};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::DisplayField::DateTime

=head1 DESCRIPTION

See L<Reaction::UI::Widget::DisplayField>

=head1 FRAGMENTS

=head2 value

C<content> contains the viewport's value_string

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

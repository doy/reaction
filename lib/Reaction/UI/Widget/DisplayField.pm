package Reaction::UI::Widget::DisplayField;

use Reaction::UI::WidgetClass;

class DisplayField, which {
  widget renders [ qw/label value/ ];
  label  renders [ string { $_{viewport}->label } ];
  value  renders [ string { $_{viewport}->value } ];
};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::DisplayField

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "label" and "field"

=head2 field

 C<content> will contain the value, if any,  of the field.

=head2 label

 C<content> will contain the label, if any, of the field.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

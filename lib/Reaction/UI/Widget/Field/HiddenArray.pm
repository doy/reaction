package Reaction::UI::Widget::Field::HiddenArray;

use Reaction::UI::WidgetClass;

class HiddenArray is 'Reaction::UI::Widget::Field', which {

  field renders [ item over func('viewport', 'value') ];
  item  renders [ string { $_ } ];

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::HiddenArray

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 FRAGMENTS

=head2 field

renders fragment C<item> over the values of 'value' arrayref

=head2 item

C<content> is $_{_} / $_ (current item in the 'value' array)

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

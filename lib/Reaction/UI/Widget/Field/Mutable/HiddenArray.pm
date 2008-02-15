package Reaction::UI::Widget::Field::Mutable::HiddenArray;

use Reaction::UI::WidgetClass;

#move this to a normal list and let the hidden part be decided by the template..
class HiddenArray is 'Reaction::UI::Widget::Field::Mutable', which {

  implements fragment hidden_list {
    render hidden_field => over $_{viewport}->value;
  };

  implements fragment hidden_field {
    arg field_value => $_;
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::Mutable::HiddenArray

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

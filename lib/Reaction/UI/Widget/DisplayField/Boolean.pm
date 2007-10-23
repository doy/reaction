package Reaction::UI::Widget::DisplayField::Boolean;

use Reaction::UI::WidgetClass;

class Boolean, which {
  widget renders [ qw/label value/ => { viewport => func(self => 'viewport') } ];
  label  renders [ string { $_{viewport}->label } ];
  value  renders [ string { $_{viewport}->value_string } ];
};

1;

__END__;

=for layout widget

[% content %]

=for layout label

<strong > [ % content %]: </strong>

=for layout value

[% content %]

=cut


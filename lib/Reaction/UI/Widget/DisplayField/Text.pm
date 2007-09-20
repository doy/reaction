package Reaction::UI::Widget::DisplayField::Text;

use Reaction::UI::WidgetClass;

class Text, which {
  widget renders [ qw/label value/ => { viewport => func(self => 'viewport') } ];
  label  renders [ string { $_{viewport}->label } ];
  value  renders [ string { $_{viewport}->value } ];
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

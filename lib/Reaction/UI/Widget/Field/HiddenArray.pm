package Reaction::UI::Widget::Field::HiddenArray;

use Reaction::UI::WidgetClass;

class HiddenArray is 'Reaction::UI::Widget::Field', which {

  field renders [ item over func('viewport', 'value') ];
  item  renders [ string { $_ } ];

};

1;


=for layout widget

[% field %]

=for layout field

[% item %]

=for layout item

<input type="hidden" name="[% name | html %]" value="[% content | html %]" />

=for layout label

=for layout message

=cut

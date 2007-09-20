package Reaction::UI::Widget::ObjectView;

use Reaction::UI::WidgetClass;

class ObjectView, which {
  widget renders [ fields => { viewport   => func('self', 'viewport') } ];
  field  renders [ viewport over func('viewport','ordered_fields')    } ];
};

1;

__END__;

=for layout widget

  [% field %]

=for layout field

  [% content %]<br>

=cut

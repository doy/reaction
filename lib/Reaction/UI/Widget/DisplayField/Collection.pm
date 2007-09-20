package Reaction::UI::Widget::DisplayField::Collection;

use Reaction::UI::WidgetClass;

class Collection, which {
  widget renders [ qw/label list item/ =>  { viewport => func(self => 'viewport') } ];
  label  renders [ string { $_{viewport}->label } ];
  list   renders [ item over func('viewport', 'value_names') ];
  item   renders [ string { $_{_} } ];
};

1;

__END__;

=for layout widget

[% label %]
[% list  %]

=for layout label

<strong > [ % content %]: </strong>

=for layout list

<ul>
[% item %]
</ul>

=for layout item

<li>[% content %]</li>

=cut

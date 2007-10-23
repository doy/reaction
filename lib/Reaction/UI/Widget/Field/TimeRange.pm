package Reaction::UI::Widget::Field::TimeRange;

use Reaction::UI::WidgetClass;

class TimeRange is 'Reaction::UI::Widget::Field', which {

};

1;


=for layout widget

[% label %] [% field %] [% message %] <br>

=for layout field

TODO

=for layout label

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <label for="[% id %]"> [% content | html %]: </label>
[% END %]

=for layout message

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <span> [% content | html %] </span>
[% END %]

=cut

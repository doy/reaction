package Reaction::UI::Widget::Field::String;

use Reaction::UI::WidgetClass;

class String is 'Reaction::UI::Widget::Field', which {

};

1;

=for layout widget

[% label %] [% field %] [% message %]

=for layout field

<!-- We need a replacement for process_attrs -->
<input type="text" name="[% name | html %]" id="[% id | html %]" value="[% content | html %]" />

=for layout label

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <label for="[% id | html %]"> [% content | html %]: </label>
[% END %]

=for layout message

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <span> [% content | html %] </span>
[% END %]

=cut

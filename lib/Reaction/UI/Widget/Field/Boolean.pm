package Reaction::UI::Widget::Field::Boolean;

use Reaction::UI::WidgetClass;

class Boolean is 'Reaction::UI::Widget::Field', which {

};

1;

=for layout widget

[% label %] [% field %] [% message %] <br>

=for layout field

[%
   IF content;
    checked = 'checked="checked"';
   ELSE;
    checked = "";
   END;
%]

<!-- We need a replacement for process_attrs -->
<input type="checkbox" id="[% id | html %]" name="[% name | html %]" value="1" [% checked %] />

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

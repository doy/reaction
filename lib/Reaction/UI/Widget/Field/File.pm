package Reaction::UI::Widget::Field::File;

use Reaction::UI::WidgetClass;

class File is 'Reaction::UI::Widget::Field', which {

};

1;


=for layout widget

[% label %] [% field %] [% message %]

=for layout field

<input type="file" name="[% name | html%]" id="[% id | html %]" />

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

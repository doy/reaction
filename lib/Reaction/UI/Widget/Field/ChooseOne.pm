package Reaction::UI::Widget::Field::ChooseOne;

use Reaction::UI::WidgetClass;

class ChooseOne is 'Reaction::UI::Widget::Field', which {

  field  renders [ option over func('viewport', 'value_choices') ],
    { is_required => sub{ $_{viewport}->attribute->required } };

  option renders [string {"DUMMY"}],
    {
     v_value  => sub { $_->{value} },
     v_name   => sub { $_->{name}  },
     is_selected => sub { $_{viewport}->is_current_value($_->{value}) },
    };

};

1;

=for layout widget

[% label %] [% field %] [% message %]

=for layout field

<!-- We need a replacement for process_attrs -->
<select name="[% name | html %]" id="[% id | html %]">
  [% IF is_required %]
    <option value="">--</option>
  [% END %]
  [% content %]
</select>

=for layout option

  [% IF is_selected;
       selected = ' selected="selected"';
     ELSE;
       selected =  '';
     END;
  %]
  <!-- I should convert this stuff to process_attrs to keep it cleaner -->
  <option value="[% v_value | html%]" [% selected %]> [% v_name | html %]</option>

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

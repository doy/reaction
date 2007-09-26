package Reaction::UI::Widget::Field::ChooseMany;

use Reaction::UI::WidgetClass;

class ChooseMany is 'Reaction::UI::Widget::Field', which {

  field renders [qw/available_values action_buttons selected_values current_values/];

  current_values renders [ hidden_value over func('viewport', 'current_value_choices')  ];
  hidden_value   renders [ string { $_->{value} } ];

  available_values renders [ option over func('viewport', 'available_value_choices') ];
  selected_values  renders [ option over func('viewport', 'current_value_choices')   ];
  option renders [string {"DUMMY"}], { v_value => sub {$_->{value}}, v_name => sub {$_->{name}} };

};

1;


=for layout widget

[% label %]
<br />
[% message %]
[% field %]

=for layout field

<table>
  <tr>
    <td> [% available_values %] </td>
    <td>  [% action_buttons %]  </td>
    <td>
      [% selected_values %]
      [% current_values  %]
    </td>
  </tr>
</table>

=for layout available_values

<select size="10" multiple="multiple"  name="[% viewport.event_id_for('add_values') | html %]">
  [% content %]
</select>

=for layout selected_values

<select size="10" multiple="multiple"  name="[% viewport.event_id_for('remove_values') | html %]">
  [% content %]
</select>

=for layout current_values

[% content %]

=for layout hidden_value

<input type="hidden" name="[% viewport.event_id_for('value') | html %]" value="[% content | html %]">

=for layout option

<option value="[% v_value | html %]">[% v_name | html %]</option>

=for layout action_buttons

<input type="submit" value="&gt;&gt;" name="[% viewport.event_id_for('add_all_values') | html %]" />
<input type="submit" value="&gt;" name="[% viewport.event_id_for('do_add_values') | html %]" /> <br />
<input type="submit" value="&lt;" name="[% viewport.event_id_for('do_remove_values') | html %]" /> <br />
<input type="submit" value="&lt;&lt;" name="[% viewport.event_id_for('remove_all_values') | html %]" /> <br />

=for layout label

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <label> [% content | html %]: </label>
[% END %]

=for layout message

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <span> [% content | html %] </span> <br />
[% END %]

=cut

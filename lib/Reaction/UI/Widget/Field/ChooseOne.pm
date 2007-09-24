package Reaction::UI::Widget::Field::ChooseOne;

use Reaction::UI::WidgetClass;

class ChooseOne is 'Reaction::UI::Widget::Field', which {

  field  renders [ option over func('viewport', 'values_list') ,
                   {name_map => func('viewport', 'value_to_name_map') }
                 ],
                   { is_required => sub{ $_{viewport}->attribute->required } };

  option renders
    [
     { v_value  => sub { $_{viewport}->obj_to_str($_) },
       v_name   => sub { $_{name_map}->{ $_{viewport}->obj_to_str($_) } },
       is_selected => sub { my $v_value = $_{viewport}->obj_to_str($_);
                            $_{viewport}->is_current_value($v_value) ||
                           $_{viewport}->value eq $v_value;
                          }
     }
    ];

};

1;

=for layout widget

[% label %] [% field %] [% message %] <br>

=for layout field

<!-- We need a replacement for process_attrs -->
<select name="[% name %]" id="[% id %]">
  [% IF is_required %]
  <option value="">--</option>
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
  <label for="[% id %]"> [% content | html %]: </label>
[% END %]

=for layout message

<!-- This conditional goes away when mst comes up with something better -->
[% IF content %]
  <span> [% content | html %] </span>
[% END %]

=cut

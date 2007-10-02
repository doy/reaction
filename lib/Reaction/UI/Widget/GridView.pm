package Reaction::UI::Widget::GridView;

use Reaction::UI::WidgetClass;

class GridView, which {
  widget renders [ qw/header rows footer/
                   => { viewport => func('self', 'viewport') }
                 ];

  header      renders [ 'header_row' ];
  header_row  renders [ header_cell over func('viewport', 'column_names') ];
  header_cell renders [ string { $_ } ];

  footer      renders [ 'footer_row' ];
  footer_row  renders [ footer_cell over func('viewport', 'column_names') ];
  footer_cell renders [ string { $_ } ];

  rows renders [ viewport over func('viewport','rows') ];

};

1;


=for layout widget
<table>
  [% header %]
<tbody>
  [% rows %]
</tbody>
<tfoot>
  [% footer %]
</tfoot>
</table>

=for layout header

<thead>
  [% content %]
</thead>

=for layout header_row

<tr>
  [% content %]
</tr>

=for layout header_cell

<th> [% content %] </th>

=for layout footer

<tfoot>
  [% content %]
</tfoot>

=for layout footer_row

<tr> [% content %] </tr>

=for layout footer_cell

<td> [% content %] </td>

=for layout rows

<tbody>
  [% content %]
</tbody>

=cut

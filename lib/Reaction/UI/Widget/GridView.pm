package Reaction::UI::Widget::GridView;

use Reaction::UI::WidgetClass;

class GridView, which {
  widget renders [ qw/header body footer/
                   => { viewport => func('self', 'viewport') }
                 ];

  header      renders [ 'header_row' ];
  header_row  renders [ header_cell over func('viewport', 'column_names') ];
  header_cell renders [ string { $_ } ];

  footer      renders [ 'footer_row' ];
  footer_row  renders [ footer_cell over func('viewport', 'column_names') ];
  footer_cell renders [ string { $_ } ];


  body      renders [ body_row over func('viewport','rows')];
  body_row  renders [ body_cell over $_ ]; #over $_ ? heeelp
  body_cell renders [ 'viewport' ];

};

1;

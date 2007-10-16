package Reaction::UI::Widget::GridView;

use Reaction::UI::WidgetClass;

class GridView, which {
  widget renders [ qw/header body footer/ ];

  header      renders [ 'header_row' ];
  header_row  renders [ header_cell over func('viewport', 'field_order'),
                        { labels => func(viewport => 'field_labels') } ];
  header_cell renders [ string { $_{labels}->{$_} } ], { field_name => $_ };

  footer      renders [ 'footer_row' ];
  footer_row  renders [ footer_cell over func('viewport', 'field_order'),
                        { labels => func(viewport => 'field_labels') } ];
  footer_cell renders [ string { $_{labels}->{$_} } ], { field_name => $_ };

  body        renders [ viewport over func('viewport','entities')];

};

1;

package Reaction::UI::Widget::GridView;

use Reaction::UI::WidgetClass;

class GridView, which {
  fragment widget [ qw/header body footer/ ];

  fragment header      [ 'header_row' ];
  fragment header_row  [ header_cell over func('viewport', 'field_order'),
                        { labels => func(viewport => 'field_labels') } ];
  fragment header_cell [ string { $_{labels}->{$_} } ], { field_name => $_ };

  fragment footer      [ 'footer_row' ];
  fragment footer_row  [ footer_cell over func('viewport', 'field_order'),
                        { labels => func(viewport => 'field_labels') } ];
  fragment footer_cell [ string { $_{labels}->{$_} } ], { field_name => $_ };

  fragment body        [ viewport over func('viewport','entities')];

};

1;

package Reaction::UI::Widget::GridView::Entity::WithActions;

use Reaction::UI::WidgetClass;

#should I use inheritance here??
class WithActions, which {
  fragment widget     [ qw(field_list actions) ];
  fragment field_list [ field => over func('viewport', 'fields') ];
  fragment field      [ 'viewport' ];

  fragment actions [ action => over func(viewport => 'actions')];
  fragment action  [ 'viewport' ];
};

1;

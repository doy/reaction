package Reaction::UI::Widget::GridView::Entity::WithActions;

use Reaction::UI::WidgetClass;

#should I use inheritance here??
class WithActions, which {
  widget  renders [ qw/fields actions/ ];
  fields  renders [ field  over func(viewport => 'fields') ];
  field   renders [ 'viewport' ];

  actions renders [ action over func(viewport => 'actions')];
  action  renders [ 'viewport' ];
};

1;

package Reaction::UI::Widget::GridView::Action;

use Reaction::UI::WidgetClass;

class Action, which {
  fragment widget [ string{ "DUMMY" } ],
    { uri => func(viewport => 'uri'), label => func(viewport => 'label') };
};

1;

__END__;


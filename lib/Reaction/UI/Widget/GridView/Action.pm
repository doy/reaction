package Reaction::UI::Widget::GridView::Action;

use Reaction::UI::WidgetClass;

class Action, which {
  widget renders [ string{ "DUMMY" } ],
    { uri => func(viewport => 'uri'), label => func(viewport => 'label') };
};

1;

__END__;


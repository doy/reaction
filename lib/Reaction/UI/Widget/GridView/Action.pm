package Reaction::UI::Widget::GridView::Action;

use Reaction::UI::WidgetClass;

class Action, which {

  before fragment widget {
    arg uri => $_{viewport}->uri;
    arg label => $_{viewport}->label;
  };

};

1;

__END__;


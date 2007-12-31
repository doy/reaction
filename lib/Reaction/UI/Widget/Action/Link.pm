package Reaction::UI::Widget::Action::Link;

use Reaction::UI::WidgetClass;

#I want to change this at some point.
class Link, which {

  before fragment widget {
    arg uri => $_{viewport}->uri;
    arg label => $_{viewport}->label;
  };

};

1;

__END__;


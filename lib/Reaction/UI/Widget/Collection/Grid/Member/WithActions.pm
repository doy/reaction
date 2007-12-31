package Reaction::UI::Widget::Collection::Grid::Member::WithActions;

use Reaction::UI::WidgetClass;

class WithActions, is 'Reaction::UI::Widget::Collection::Grid::Member', which {

  implements fragment actions {
    render action => over $_{viewport}->actions;
  };

  implements fragment action {
    render 'viewport';
  };

};

1;

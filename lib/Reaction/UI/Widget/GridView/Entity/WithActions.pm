package Reaction::UI::Widget::GridView::Entity::WithActions;

use Reaction::UI::WidgetClass;

class WithActions, is 'Reaction::UI::Widget::GridView::Entity', which {

  implements fragment actions {
    render action => over $_{viewport}->actions;
  };
  
  implements fragment action {
    render 'viewport';
  };

};

1;

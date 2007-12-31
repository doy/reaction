package Reaction::UI::Widget::Collection;

use Reaction::UI::WidgetClass;

class Collection, which {

  implements fragment members {
    render member => over $_{viewport}->members;
  };

  implements fragment member {
    render 'viewport';
  };

};

1;

__END__;

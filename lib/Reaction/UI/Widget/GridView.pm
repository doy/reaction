package Reaction::UI::Widget::GridView;

use Reaction::UI::WidgetClass;

class GridView, which {

  implements fragment header_cells {
    arg 'labels' => $_{viewport}->field_labels;
    render header_cell => over $_{viewport}->field_order;
  };

  implements fragment body_rows {
    render body_row => over $_{viewport}->entities;
  };

  implements fragment body_row {
    render 'viewport';
  };

  implements fragment header_cell {
    arg label => $_{labels}->{$_};
  };

};

1;

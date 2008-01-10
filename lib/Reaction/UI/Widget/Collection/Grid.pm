package Reaction::UI::Widget::Collection::Grid;

use Reaction::UI::WidgetClass;

class Grid is 'Reaction::UI::Widget::Collection', which {

  implements fragment header_cells {
    arg 'labels' => $_{viewport}->field_labels;
    render header_cell => over $_{viewport}->computed_field_order;
  };

  implements fragment header_cell {
    arg label => $_{labels}->{$_};
  };

};

1;

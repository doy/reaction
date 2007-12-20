package Reaction::UI::Widget::ListView;

use Reaction::UI::WidgetClass;

class ListView is 'Reaction::UI::Widget::GridView', which {

  implements fragment actions {
    render action => over $_{viewport}->actions;
  };

  implements fragment action {
    render 'viewport';
  };

  around fragment header_cell {
    arg order_uri => event_uri {
      order_by => $_,
      order_by_desc => ((($_{viewport}->order_by||'') ne $_
                        || $_{viewport}->order_by_desc) ? 0 : 1)
    };
    call_next;
  };

  after fragment header_cells {
    if ($_{viewport}->object_action_count) {
      render 'header_action_cell';
    }
  };

  implements fragment header_action_cell {
    arg 'col_count' => $_{viewport}->object_action_count;
  };

};

1;

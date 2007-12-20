package Reaction::UI::Widget::ListView;

use Reaction::UI::WidgetClass;

class ListView is 'Reaction::UI::Widget::GridView', which {

  after fragment widget {
    arg pager_obj => $_{viewport}->pager;
  };

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
    arg col_count => $_{viewport}->object_action_count;
  };

  implements fragment page_list {
    render numbered_page_fragment
      => over [ $_{pager_obj}->first_page .. $_{pager_obj}->last_page ];
  };

  implements fragment numbered_page_fragment {
    arg page_uri => event_uri { page => $_ };
    arg page_number => $_;
    if ($_{pager_obj}->current_page == $_) {
      render 'numbered_page_this_page';
    } else {
      render 'numbered_page';
    }
  };

  implements fragment first_page {
    arg page_uri => event_uri { page => $_{pager_obj}->first_page };
    arg page_name => 'First';
    render 'named_page';
  };

  implements fragment last_page {
    arg page_uri => event_uri { page => $_{pager_obj}->last_page };
    arg page_name => 'Last';
    render 'named_page';
  };

  implements fragment next_page {
    arg page_name => 'Next';
    if (my $page = $_{pager_obj}->next_page) {
      arg page_uri => event_uri { page => $page };
      render 'named_page';
    } else {
      render 'named_page_no_page';
    }
  };

  implements fragment previous_page {
    arg page_name => 'Previous';
    if (my $page = $_{pager_obj}->previous_page) {
      arg page_uri => event_uri { page => $page };
      render 'named_page';
    } else {
      render 'named_page_no_page';
    }
  };

};

1;

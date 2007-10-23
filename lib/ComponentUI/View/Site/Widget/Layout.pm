package ComponentUI::View::Site::Widget::Layout;

use Reaction::UI::WidgetClass;

class Layout which {

  widget renders  [ qw(menu sidebar header main_content) =>
                    { viewport => func('self', 'viewport') } ];

  menu         renders [ string { "DUMMY" }        ];
  sidebar      renders [ string { "Sidebar Shit" } ];
  header       renders [ string { "DUMMY" }        ];
  main_content renders [ viewport over func('viewport', 'inner')];

};

1;

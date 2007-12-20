package ComponentUI::View::Site::Widget::Layout;

use Reaction::UI::WidgetClass;

class Layout which {

  fragment  widget [ qw(menu sidebar header main_content) ];

  fragment menu         [ string { "DUMMY" }        ];
  fragment sidebar      [ string { "Sidebar Shit" } ];
  fragment header       [ string { "DUMMY" }        ];
  fragment main_content [ viewport over func('viewport', 'inner')];

};

1;

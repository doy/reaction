package ComponentUI::View::Site::Widget::Layout;

use Reaction::UI::WidgetClass;

class Layout which {

  implements fragment main_content {
    if (my $inner = $_{viewport}->inner) {
      arg '_' => $inner;
      render 'viewport';
    }
  };

};

1;

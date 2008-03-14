package Reaction::UI::Widget::Value::Image;

use Reaction::UI::WidgetClass;

class Image, which {

  implements fragment image {
    warn $_{viewport};
      if($_{viewport}->value_string) {
      arg uri => $_{viewport}->uri;
      render 'has_image';
    } else {
      render 'no_image';
    }
  };

};

1;

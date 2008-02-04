package Reaction::UI::Widget::Field::Image;

use Reaction::UI::WidgetClass;

class Image is 'Reaction::UI::Widget::Field', which {
   
  implements fragment image {
    if($_{viewport}->value_string) {
      arg uri => $_{viewport}->uri;
      render 'has_image';
    } else {
      render 'no_image';
    }
  };

};

1;

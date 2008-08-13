package Reaction::UI::Widget::Field::Image;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Field';


 
implements fragment image {
  if($_{viewport}->value_string) {
    arg uri => $_{viewport}->uri;
    render 'has_image';
  } else {
    render 'no_image';
  }
};

__PACKAGE__->meta->make_immutable;


1;

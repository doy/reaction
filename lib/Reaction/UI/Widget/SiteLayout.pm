package Reaction::UI::Widget::SiteLayout;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::Widget::Container';

class SiteLayout is Container, which {

  after fragment widget {
    arg static_base => $_{viewport}->static_base_uri;
    arg title => $_{viewport}->title;
  };

};

1;

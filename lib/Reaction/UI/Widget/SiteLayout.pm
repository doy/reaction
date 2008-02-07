package Reaction::UI::Widget::SiteLayout;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::Widget::Container';

class SiteLayout is Container, which {

  after fragment widget {
    arg static_base => $_{viewport}->static_base_uri;
    arg title => $_{viewport}->title;
  };

  implements fragment meta_info {
    render meta_member => over [keys %{$_{viewport}->meta_info}];
  };

  implements fragment meta_member {
    arg 'meta_name' => $_;
    arg 'meta_value' => $_{viewport}->meta_info->{$_};
  };

};

1;

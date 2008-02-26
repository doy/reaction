package Reaction::UI::Widget::Field::Mutable::MatchingPasswords;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::Widget::Field::Mutable::Password';

class MatchingPasswords is Password, which {

  implements fragment check_value {
    arg 'field_id'   => event_id 'check_value';
    arg 'field_name' => event_id 'check_value';
    render 'field'; #piggyback!
  };

};

1;

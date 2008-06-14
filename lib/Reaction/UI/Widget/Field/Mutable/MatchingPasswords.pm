package Reaction::UI::Widget::Field::Mutable::MatchingPasswords;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::Widget::Field::Mutable::Password';

class MatchingPasswords is Password, which {

  implements fragment check_field {
    arg 'field_id'   => event_id 'check_value';
    arg 'field_name' => event_id 'check_value';
    arg 'label' => 'Confirm:';
    render 'field'; #piggyback!
  };

  implements fragment check_label {
    if (my $label = $_{viewport}->check_label) {
      arg label => $label;
      render 'label';
    }
  };


};

1;

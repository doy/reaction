package Reaction::UI::Widget::Field;

use Reaction::UI::WidgetClass;

class Field, which {

  has id   => (isa => 'Str', is => 'ro', lazy_build => 1);
  has name => (isa => 'Str', is => 'ro', lazy_build => 1);

  implements build_id   => as { shift->viewport->event_id_for('value'); };
  implements build_name => as { shift->viewport->event_id_for('value'); };

  widget renders [qw/label field message/
                  => { id       => func('self', 'id'),
                       name     => func('self', 'name'),
                       viewport => func('self', 'viewport'),  }
                 ];

  label   renders [ string { $_{viewport}->label   }, ];
  message renders [ string { $_{viewport}->message }, ];

  field  renders [ string { $_{viewport}->value },  ];

};

1;


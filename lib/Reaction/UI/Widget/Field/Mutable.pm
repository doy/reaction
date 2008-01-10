package Reaction::UI::Widget::Field::Mutable;

use Reaction::UI::WidgetClass;

class Mutable is 'Reaction::UI::Widget::Field', which {

   before fragment widget {
     arg 'field_id' => event_id 'value';
     arg 'field_name' => event_id 'value';
     arg 'field_type' => 'text';
   };

   implements fragment message_fragment {
     if (my $message = $_{viewport}->message) {
       arg message => $message;
       render 'message';
     }
   };

};

1;

__END__;

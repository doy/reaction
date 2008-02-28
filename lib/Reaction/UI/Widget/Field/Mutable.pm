package Reaction::UI::Widget::Field::Mutable;

use Reaction::UI::WidgetClass;

class Mutable is 'Reaction::UI::Widget::Field', which {

   before fragment widget {
     arg 'field_id' => event_id 'value_string';
     arg 'field_name' => event_id 'value_string' unless defined $_{field_name};
     arg 'field_type' => 'text';
   };

   implements fragment message_fragment {
     if (my $message = $_{viewport}->message) {
       arg message => $message;
       render 'message';
     }
   };

   implements fragment field_is_required {
     my $model = $_{viewport}->model;
     my $attr  = $_{viewport}->attribute;
     if ( $model->attribute_is_required($attr) ) {
         render 'field_is_required_yes';
     } else {
         render 'field_is_required_no';
     }
   };

};

1;

__END__;

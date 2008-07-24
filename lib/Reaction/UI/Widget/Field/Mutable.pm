package Reaction::UI::Widget::Field::Mutable;

use Reaction::UI::WidgetClass;

class Mutable is 'Reaction::UI::Widget::Field', which {

   before fragment widget {
     arg 'field_id' => event_id 'value_string';
     my $field_name = event_id 'value_string' unless defined $_{field_name};
     arg 'field_name' => $field_name;
     arg 'field_type' => 'text';
     my $field_class = $field_name;
     $field_class =~ s/\d\-//;
     arg 'field_class' => $field_class;

     # these two are to fire force_events in viewports
     # where you can end up without an event for e.g.
     # HTML checkbox fields

     arg 'exists_event' => event_id 'exists';
     arg 'exists_value' => 1;
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

package Reaction::UI::Widget::Field::Mutable;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Field';



 before fragment widget {
   arg 'field_id' => event_id 'value_string';
   arg 'field_name' => event_id 'value_string' unless defined $_{field_name};
   arg 'field_type' => 'text';
   arg 'field_class' => "action-field " . $_{viewport}->name;

   # these two are to fire force_events in viewports
   # where you can end up without an event for e.g.
   # HTML checkbox fields

   arg 'exists_event' => event_id 'exists';
   arg 'exists_value' => 1;
 };

 implements fragment message_fragment {
   if (my $message = $_{viewport}->message) {
     arg message => localized $message;
     render 'message';
   }
 };

 implements fragment field_is_required {
   my $vp = $_{viewport};
   if ( $vp->value_is_required && !$vp->value_string ) {
       render 'field_is_required_yes';
   } else {
       render 'field_is_required_no';
   }
 };

__PACKAGE__->meta->make_immutable;


1;

__END__;

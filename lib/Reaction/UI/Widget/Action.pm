package Reaction::UI::Widget::Action;

use Reaction::UI::WidgetClass;

class Action is 'Reaction::UI::Widget::Object', which {

  #before fragment widget {
  #  arg form_id => $_{viewport}->location;
  #};

  implements fragment ok_button_fragment {
    if (grep { $_ eq 'ok' } $_{viewport}->accept_events) {
      arg 'event_id' => event_id 'ok';
      arg 'label' => $_{viewport}->ok_label;
      render 'ok_button';
    }
  };

  implements fragment apply_button_fragment {
    if (grep { $_ eq 'apply' } $_{viewport}->accept_events) {
      arg 'event_id' => event_id 'apply';
      arg 'label' => $_{viewport}->apply_label;
      render 'apply_button';
    }
  };

  implements fragment cancel_button_fragment {
    if (grep { $_ eq 'close' } $_{viewport}->accept_events) {
      arg 'event_id' => event_id 'close';
      arg 'label' => $_{viewport}->close_label;
      render 'cancel_button';
    }
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Action

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 ok_button_fragment

=head2 apply_button_fragment

=head2 cancel_button_fragment

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


package Reaction::UI::Widget::ActionForm;

use Reaction::UI::WidgetClass;

class ActionForm, which {

  #implements fragment widget {
  #  arg form_id => $_{viewport}->location;
  #};

  implements fragment field_list {
    render field => over $_{viewport}->ordered_fields;
  };

  implements fragment field {
    render 'viewport';
  };

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
    if (grep { $_ eq 'cancel' } $_{viewport}->accept_events) {
      arg 'event_id' => event_id 'cancel';
      arg 'label' => $_{viewport}->cancel_label;
      render 'cancel_button';
    }
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::ActionForm

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "header", "field_list", "buttons" and "footer"

=head2 field_list

Sequentially renders the C<ordered_fields> of the viewport

=head2 buttons

Additional variables available in topic hash: "message"

=head2 header

Content is a dummy value

=head2 footer

Content is a dummy value

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


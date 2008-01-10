package Reaction::UI::Widget::Field;

use Reaction::UI::WidgetClass;

class Field, which {

  before fragment widget {
    if ($_{viewport}->can('value_string')) {
      arg 'field_value' => $_{viewport}->value_string;
    } else {
      arg 'field_value' => $_{viewport}->value;
    }
  };

  implements fragment label_fragment {
    if (my $label = $_{viewport}->label) {
      arg label => $label;
      render 'label';
    }
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 id

Str, lazy builds.

=head2 name

Str, lazy builds.

=head1 METHODS

=head2 _build_id

Returns the viewport's C<event_id_for('value')>

=head2 _build_name

Returns the viewport's C<event_id_for('value')>

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport", "id", "name".

Renders "label","field" and "message"

=head2 field

 C<content> will contain the value, if any,  of the field.

=head2 label

 C<content> will contain the label, if any, of the field.

=head2 message

 C<content> will contain the message, if any, of the field.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

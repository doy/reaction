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

=head2 build_id

Returns the viewport's C<event_id_for('value')>

=head2 build_name

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

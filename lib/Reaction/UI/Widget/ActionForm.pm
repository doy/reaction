package Reaction::UI::Widget::ActionForm;

use Reaction::UI::WidgetClass;

class ActionForm, which {
  widget renders [ qw/header fields buttons footer/ ],
    {id => sub { $_{viewport}->location } };

  fields renders [field over func('viewport','ordered_fields')];
  field  renders [ 'viewport' ];

  #move button logic here
  buttons renders [ string {"DUMMY"} ],
    { message => sub{ $_{viewport}->can('message') ? $_{viewport}->message : "" },
      ok_label    => func(viewport => 'ok_label'),
      close_label => func(viewport => 'close_label'),
      apply_label => func(viewport => 'apply_label'),
    };

  header  renders [ string {"DUMMY"} ];
  footer  renders [ string {"DUMMY"} ];

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::ActionForm

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "header", "fields", "buttons" and "footer"

=head2 fields

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


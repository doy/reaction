package Reaction::UI::Widget::ActionForm;

use Reaction::UI::WidgetClass;

class ActionForm, which {
  fragment widget [ qw/header field_list buttons footer/ ];

  fragment field_list [field over func('viewport','ordered_fields')];
  fragment field  [ 'viewport' ];

  #move button logic here
  fragment buttons [ string {"DUMMY"} ],
    { message => sub{ $_{viewport}->can('message') ? $_{viewport}->message : "" },
      ok_label    => func(viewport => 'ok_label'),
      close_label => func(viewport => 'close_label'),
      apply_label => func(viewport => 'apply_label'),
    };

  fragment header  [ string {"DUMMY"} ];
  fragment footer  [ string {"DUMMY"} ];

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


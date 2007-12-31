package Reaction::UI::Widget::ObjectView;

use Reaction::UI::WidgetClass;

class ObjectView, which {

  implements fragment field_list {
    render field => over $_{viewport}->ordered_fields;
  };

  implements fragment field {
    render 'viewport';
  };

};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::ObjectView

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "field_list"

=head2 field_list

Sequentially renders the C<ordered_fields> of the viewport

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

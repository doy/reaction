package Reaction::UI::Widget::GridView::Entity;

use Reaction::UI::WidgetClass;

class Entity, which {

  implements fragment field_list {
    render 'field' => over $_{viewport}->fields;
  };

  implements fragment field {
    render 'viewport';
  };

};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::GridView::Entity

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "field_list"

=head2 field_list

Sequentially renders the C<fields> of the viewport as "field"

=head2 field

renders the cell value

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

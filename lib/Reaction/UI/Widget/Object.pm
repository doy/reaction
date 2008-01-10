package Reaction::UI::Widget::Object;

use Reaction::UI::WidgetClass;

class Object, which {

  implements fragment field_list {
    render field => over $_{viewport}->fields;
  };

  implements fragment field {
    render 'viewport';
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Object

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 field_list

Sequentially renders the C<fields> of the viewport in the C<computed_field_order>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

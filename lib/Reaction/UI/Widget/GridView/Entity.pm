package Reaction::UI::Widget::GridView::Entity;

use Reaction::UI::WidgetClass;

class Entity, which {
  #this could be flattened if i could do:
  # widget renders [field over sub{ $_{self}->viewport->fields } ];
  #to be honest, I think that the key viewport should be available by default in %_
  widget renders [ 'fields' ];
  fields renders [ field over func('viewport', 'fields') ];
  field  renders [ 'viewport' ];
};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::GridView::Entity

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "fields"

=head2 fields

Sequentially renders the C<fields> of the viewport as "field"

=head2 field

renders the cell value

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

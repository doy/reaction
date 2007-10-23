package Reaction::UI::Widget::ObjectView;

use Reaction::UI::WidgetClass;

class ObjectView, which {
  widget renders [ cells => { viewport => func('self', 'viewport') } ];
  cells  renders [ cell over func('viewport', 'ordered_fields')   ];
  cell   renders [ 'viewport' ];
};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::GridView::Row

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "cells"

=head2 cells

Sequentially renders the C<ordered_fields> of the viewport as "cell"

=head2 cell

renders the cell value

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

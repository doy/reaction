package Reaction::UI::Widget::ObjectView;

use Reaction::UI::WidgetClass;

class ObjectView, which {
  widget renders [ 'fields' ];
  fields renders [ field over func('viewport', 'ordered_fields')   ];
  field  renders [ 'viewport' ];
};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::ObjectView

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "fields"

=head2 fields

Sequentially renders the C<ordered_fields> of the viewport

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

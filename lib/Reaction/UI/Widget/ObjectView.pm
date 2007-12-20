package Reaction::UI::Widget::ObjectView;

use Reaction::UI::WidgetClass;

class ObjectView, which {
  fragment widget [ 'field_list' ];
  fragment field_list [ field => over func('viewport', 'ordered_fields')   ];
  fragment field  [ 'viewport' ];
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

package Reaction::UI::Widget::Object;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];

implements fragment container_list {
  render container => over $_{viewport}->containers;
};

implements fragment container {
  render 'viewport';
};

#we won't be needing these anymore
implements fragment field_list {
  render field => over $_{viewport}->fields;
};

implements fragment field {
  render 'viewport';
};

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Object - Widget to implement rendering of an object

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 container_list

Sequentially renders the C<fields> of the viewport found in its C<containers>
method return values.

=head2 container

Renders the C<field> viewport passed by C<container_list>.

=head1 DEPRECATED FRAGMENTS

=head2 field_list

Sequentially renders the C<fields> of the viewport;

=head2 field

Renders the C<field> viewport passed by C<field_list>

=head1 LAYOUT SETS

=head2 base

  share/skin/base/layout/object.tt

The following layouts are provided:

=over 4

=item widget

Renders the C<container_list> fragment.

=item container

Renders the container viewport.

=back

=head2 default

  share/skin/default/layout/object.tt

This layout set inherits from the one with the same name in the C<base> skin.

The following layouts are provided:

=over 4

=item container

Renders the container viewport.

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

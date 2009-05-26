package Reaction::UI::Widget::Collection::Grid::Member::WithActions;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Collection::Grid::Member';

implements fragment actions {
  render action => over $_{viewport}->actions;
};

implements fragment action {
  render 'viewport';
};

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Collection::Grid::Member::WithActions - Grid members with actions

=head1 DESCRIPTION

This is a subclass of L<Reaction::UI::Widget::Grid::Member> additionally
providing actions per member.

=head1 FRAGMENTS

=head2 actions

Renders the C<action> fragment with every item in the viewports C<actions>.

=head2 action

Renders the C<viewport> fragment provided by L<Reaction::UI::Widget>, thus
rendering the current viewport stored in the C<_> topic argument provided
by the C<actions> fragment.

=head1 LAYOUT SETS

=head2 base

  share/skin/base/layout/collection/grid/member/with_actions.tt

This layout set extends the C<collection/grid/member> layout set in the parent
skin.

The following layouts are provided:

=over 4

=item field_list

First renders the original C<field_list> fragment, then the C<actions> fragment.

=item action

Simply renders the next C<action> fragment in line.

=back

=head2 default

  share/skin/default/layout/collection/grid/member/with_actions.tt

This layout skin extends the C<collection/grid/member> layout set in the parent
skin.

The following layouts are provided:

=over 4

=item field_list

The same as in the C<base> skin.

=item action

Renders the original C<action> fragment surrounded by a C<td> element.

=back

=head1 SEE ALSO

=over 4

=item * L<Reaction::UI::Widget::Grid::Member>

=item * L<Reaction::UI::Widget::Grid>

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

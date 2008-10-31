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

Reaction::UI::Widget::Grid::Member::WithActions

=head1 DESCRIPTION

=head1 FRAGMENTS

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::Widget::Collection::Grid;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Collection';

implements fragment header_cells {
  arg 'labels' => $_{viewport}->field_labels;
  render header_cell => over $_{viewport}->computed_field_order;
  if ($_{viewport}->member_action_count) {
    render 'header_action_cell';
  }
};

implements fragment header_cell {
  arg label => localized $_{labels}->{$_};
};

implements fragment header_action_cell {
  arg col_count => $_{viewport}->member_action_count;
};

__PACKAGE__->meta->make_immutable;

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Grid

=head1 DESCRIPTION

=head1 FRAGMENTS

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

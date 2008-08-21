package Reaction::UI::Widget::Field::Container;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];

before fragment widget {
  arg name  => $_{viewport}->name;
};

implements fragment maybe_label {
  return unless $_{viewport}->has_label;
  arg label => $_{viewport}->label;
  render 'label';
};

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

Reaction::UI::Widget::Field::Container

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 field_list

Sequentially renders the C<fields> of the viewport;

=head2 field

Renders the C<field> viewport passed by C<field_list>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut


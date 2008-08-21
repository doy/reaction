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

Reaction::UI::Widget::Object

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 container_list

Sequentially renders the C<fields> of the viewport;

=head2 container

Renders the C<field> viewport passed by C<field_list>

=head1 DEPRECATED FRAGMENTS

=head2 field_list

Sequentially renders the C<fields> of the viewport;

=head2 field

Renders the C<field> viewport passed by C<field_list>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

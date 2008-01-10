package Reaction::UI::Widget::Value;

use Reaction::UI::WidgetClass;

class Value, which {

  before fragment widget {
    arg value => $_{viewport}->value_string;
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Value

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional available arguments

=over 4

=item B<value> - The C<value_string> of the viewport

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

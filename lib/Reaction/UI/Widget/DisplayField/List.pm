package Reaction::UI::Widget::DisplayField::List;

use Reaction::UI::WidgetClass;

class List, which {
  fragment widget [ qw/label list item/ ];
  fragment label  [ string { $_{viewport}->label } ];
  fragment list   [ item => over func('viewport', 'value_names') ];
  fragment item   [ string { $_ } ];
};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::DisplayField::List

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

renders C<label> and C<list> passing additional variable "viewport"

=head2 label

C<content> contains the viewport's label

=head2 list

renders fragment item over the viewport's C<value_names>

=head2 item

C<content> contains the value of the current item ($_ / $_{_})

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

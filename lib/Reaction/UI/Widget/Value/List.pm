package Reaction::UI::Widget::Value::List;

use Reaction::UI::WidgetClass;

class List, which {
  widget renders [ qw/list item/ =>  { viewport => func(self => 'viewport') } ];
  list   renders [ item over func('viewport', 'value_names') ];
  item   renders [ string { $_{_} } ];
};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Value::List

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

renders C<label> passing additional variable "viewport"

=head2 list

renders fragment item over the viewport's C<value_names>

=head2 item

C<content> contains the value of the current item ($_ / $_{_})

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

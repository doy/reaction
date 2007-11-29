package Reaction::UI::Widget::Value::Collection;

use Reaction::UI::WidgetClass;

class Collection, which {

  before fragment widget {
    arg 'label' => $_{viewport}->label;
  };

  implements fragment list {
    render 'item' => over $_{viewport}->value_names;
  };

  implements fragment item {
    arg 'name' => $_;
  };

};

1;

__END__;


=head1 NAME

Reaction::UI::Widget::Value::Collection

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

renders C<label> and C<list> passing additional variable "viewport"

=head2 list

renders fragment item over the viewport's C<value_names>

=head2 item

C<content> contains the value of the current item ($_ / $_{_})

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::Widget::Field::Mutable::Boolean;

use Reaction::UI::WidgetClass;

class Boolean is 'Reaction::UI::Widget::Field::Mutable', which {

  after fragment widget {
     arg 'field_type' => 'checkbox';
  };
  
  implements fragment is_checked {
    if ($_{viewport}->value_string) {
      render 'is_checked_yes';
    } else {
      render 'is_checked_no';
    }
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::Boolean

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

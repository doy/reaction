package Reaction::UI::Widget::Field::Mutable::ChooseOne;

use Reaction::UI::WidgetClass;

class ChooseOne is 'Reaction::UI::Widget::Field::Mutable', which {

  implements fragment option_is_required {
    if ($_{viewport}->value_is_required) {
      render 'option_is_required_yes';
    } else {
      render 'option_is_required_no';
    }
  };

  implements fragment option_list {
    render option => over $_{viewport}->value_choices;
  };

  implements fragment option {
    arg option_name => $_->{name};
    arg option_value => $_->{value};
  };

  implements fragment option_is_selected {
    if ($_{viewport}->is_current_value($_->{value})) {
      render 'option_is_selected_yes';
    } else {
      render 'option_is_selected_no';
    }
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::ChooseOne

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 FRAGMENTS

=head2 field

Renders a series fragment C<option> for each C<value_choices> in the viewport

Additional varibles set: C<is_required> - Boolean, self-explanatory

=head2 option

C<content> is a dummy variable, but th additional variables C<v_value>, C<v_name>
and C<is_selected> are set

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

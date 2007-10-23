package Reaction::UI::Widget::Field::ChooseOne;

use Reaction::UI::WidgetClass;

class ChooseOne is 'Reaction::UI::Widget::Field', which {

  field  renders [ option over func('viewport', 'value_choices') ],
    { is_required => sub{ $_{viewport}->attribute->required } };

  option renders [string {"DUMMY"}],
    {
     v_value  => sub { $_->{value} },
     v_name   => sub { $_->{name}  },
     is_selected => sub { $_{viewport}->is_current_value($_->{value}) },
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

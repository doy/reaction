package Reaction::UI::Widget::Field::ChooseMany;

use Reaction::UI::WidgetClass;

class ChooseMany is 'Reaction::UI::Widget::Field', which {

  field renders [qw/available_values action_buttons selected_values current_values/];

  current_values renders [ hidden_value over func('viewport', 'current_value_choices')  ];
  hidden_value   renders [ string { $_->{value} } ];

  available_values renders [ option over func('viewport', 'available_value_choices') ];
  selected_values  renders [ option over func('viewport', 'current_value_choices')   ];
  option renders [string {"DUMMY"}], { v_value => sub {$_->{value}}, v_name => sub {$_->{name}} };

};

1;


=head1 NAME

Reaction::UI::Widget::Field::ChooseMany

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

This needs a refactor to not be tied to a dual select box, but ENOTIME

=head1 FRAGMENTS

=head2 field

renders C<available_values>, C<action_buttons>, C<selected_values> and C<current_values>

=head2 current values

renders the viewport's current_value_choices over hidden_value

=head2 hidden_value

C<content> is the value of the current choice

=head2 available_value

rendersthe viewport's current_available_value_choices over the option fragment

=head2 selected_value

rendersthe viewport's current_selected_value_choices over the option fragment

=head2 option

C<content> is a dummy value but C<v_value> and C<v_name> are both set.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::Widget::Field::Mutable::ChooseMany;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Field::Mutable';



implements fragment action_buttons {
  foreach my $event (
    qw(add_all_values do_add_values do_remove_values remove_all_values)
      ) {
    arg "event_id_${event}" => event_id $event;
  }
};

implements fragment current_values {
  my $current_choices = $_{viewport}->current_value_choices;
  if( @$current_choices ){
    arg field_name => event_id 'value';
    render hidden_value => over $current_choices;
  } else {
    arg field_name => event_id 'no_current_value';
    arg '_' => {value => 1};
    render 'hidden_value';
  }
};

implements fragment selected_values {
  arg event_id_remove_values => event_id 'remove_values';
  render value_option => over $_{viewport}->current_value_choices;
};

implements fragment available_values {
  arg event_id_add_values => event_id 'add_values';
  render value_option => over $_{viewport}->available_value_choices;
};

implements fragment value_option {
  arg option_name => $_->{name};
  arg option_value => $_->{value};
};

implements fragment hidden_value {
  arg hidden_value => $_->{value};
};

__PACKAGE__->meta->make_immutable;


1;

__END__;

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

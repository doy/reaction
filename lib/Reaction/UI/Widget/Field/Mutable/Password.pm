package Reaction::UI::Widget::Field::Mutable::Password;

use Reaction::UI::WidgetClass;

class Password is 'Reaction::UI::Widget::Field::Mutable', which {

  around fragment widget {
    call_next;
    arg field_type => 'password';
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::Password

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

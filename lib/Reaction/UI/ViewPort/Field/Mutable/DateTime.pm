package Reaction::UI::ViewPort::Field::Mutable::DateTime;

use Reaction::Class;
use Time::ParseDate;
use DateTime;

class 'Reaction::UI::ViewPort::Field::Mutable::DateTime',
  is 'Reaction::UI::ViewPort::Field::DateTime', which {

  does 'Reaction::UI::ViewPort::Field::Role::Mutable::Simple';

  implements adopt_value_string => as {
    my ($self) = @_;
    my $value = $self->value_string;
    my ($epoch) = Time::ParseDate::parsedate($value);
    if (defined $epoch) {
      my $dt = 'DateTime'->from_epoch( epoch => $epoch );
      $self->value($dt);
    } else {
      $self->value($self->value_string);
    }
  };

};

1;


=head1 NAME

Reaction::UI::ViewPort::Field::DateTime

=head1 DESCRIPTION

=head1 METHODS

=head2 value_string

Accessor for the string representation of the DateTime object.

=head2 value_string_default_format

By default it is set to "%F %H:%M:%S".

=head1 SEE ALSO

=head2 L<DateTime>

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

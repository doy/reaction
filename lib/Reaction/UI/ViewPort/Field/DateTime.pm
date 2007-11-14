package Reaction::UI::ViewPort::Field::DateTime;

use Reaction::Class;
use Reaction::Types::DateTime;
use Time::ParseDate ();

class DateTime is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => 'DateTime');

  #has '+layout' => (default => 'dt_textfield');

  has value_string => (
    isa => 'Str', is => 'rw', lazy_build => 1,
    trigger_adopt('value_string')
  );

  has value_string_default_format => (
    isa => 'Str', is => 'rw', required => 1, default => sub { "%F %H:%M:%S" }
  );

  implements _build_value_string => as {
    my $self = shift;

    # XXX
    #<mst> aha, I know why the fucker's lazy
    #<mst> it's because if value's calculated
    #<mst> it needs to be possible to clear it
    #<mst> eval { $self->value } ... is probably the best solution atm
    my $value = eval { $self->value };
    return '' unless $self->has_value;
    my $format = $self->value_string_default_format;
    return $value->strftime($format) if $value;
    return '';
  };

  implements adopt_value_string => as {
    my ($self) = @_;
    my $value = $self->value_string;
    my ($epoch) = Time::ParseDate::parsedate($value, UK => 1);
    if (defined $epoch) {
      my $dt = 'DateTime'->from_epoch( epoch => $epoch );
      $self->value($dt);
    } else {
      $self->message("Could not parse date or time");
      $self->clear_value;
      $self->needs_sync(1);
    }
  };

  override accept_events => sub {
    ('value_string', super());
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

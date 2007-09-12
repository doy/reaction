package Reaction::Types::DateTime;

use Moose::Util::TypeConstraints;

use DateTime;

subtype 'DateTime'
  => as 'Object'
  => where { $_->isa('DateTime') }
  => message { "Must be of the form YYYY-MM-DD HH:MM:SS" };

use DateTime::SpanSet;

subtype 'DateTime::SpanSet'
  => as 'Object'
  => where { $_->isa('DateTime::SpanSet') };

subtype 'TimeRangeCollection'
  => as 'ArrayRef';

1;

=head1 NAME

Reaction::Types::DateTime

=head1 DESCRIPTION

=over 

=item * DateTime

=item * DateTime::SpanSet

=item * TimeRangeCollection

=back

=head1 SEE ALSO

=over 

=item * L<Reaction::Types::Core>

=back

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

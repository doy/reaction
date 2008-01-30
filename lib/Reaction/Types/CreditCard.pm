package Reaction::Types::CreditCard;

use MooseX::Types
    -declare => [qw/CardNumber CheckNumber/];

use Reaction::Types::Core qw/NonEmptySimpleStr PositiveInt/;
use Business::CreditCard ();

subtype CardNumber
    => as NonEmptySimpleStr
    => where   { Business::CreditCard::validate($_) }
    => message {"Must be a valid card number"};

subtype CheckNumber
  => as PositiveInt
  => where { $_ <= 999 }
  => message { "Must be a 3 digits number" };

1;

=head1 NAME

Reaction::Types::CreditCard

=head1 DESCRIPTION

=over

=item * CardNumber

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

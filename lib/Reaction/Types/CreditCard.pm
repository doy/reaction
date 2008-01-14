package Reaction::Types::CreditCard;

use MooseX::Types
    -declare => [qw/CardNumber/];

use Reaction::Types::Core 'NonEmptySimpleStr';
use Business::CreditCard;

subtype 'CardNumber'
    => as 'NonEmptySimpleStr'
    => where   { Business::CreditCard->validate($_) }
    => message {"Must be a valid card number"};

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

package Reaction::Types::DBIC;

use MooseX::Types
    -declare => [qw/ResultSet Row/];

use MooseX::Types::Moose 'Object';
use DBIx::Class::ResultSet;

subtype 'ResultSet'
  => as 'Object'
  => where { $_->isa('DBIx::Class::ResultSet') };

use DBIx::Class::Core;
use DBIx::Class::Row;

subtype 'Row'
  => as 'Object'
  => where { $_->isa('DBIx::Class::Row') };

1;

=head1 NAME

Reaction::Types::DBIC

=head1 DESCRIPTION

=over

=item * DBIx::Class::ResultSet

=item * DBIx::Class::Row

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

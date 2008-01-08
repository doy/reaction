package Reaction::Types::File;

use MooseX::Types
    -declare => [qw/File/];

use MooseX::Types::Moose 'Object';
use Catalyst::Request::Upload;

subtype 'File'
  => as 'Object'
  => where { $_->isa('Catalyst::Request::Upload') }
  => message { "Must be a file" };

1;

=head1 NAME

Reaction::Types::File

=head1 DESCRIPTION

=over 

=item * File

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

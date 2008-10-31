package Reaction::UI::ViewPort::Image;

use Reaction::Class;
use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort';

has uri => ( is => 'rw', isa => 'URI', required => 1);
has width => ( is => 'rw', isa => 'Int');
has height => ( is => 'rw', isa => 'Int');

__PACKAGE__->meta->make_immutable;

1;

__END__;


=head1 NAME

Reaction::UI::ViewPort::Image

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 uri

Required URI object pointing to the image to be displayed.

=head2 width

Optional width in pixels.

=head2 height

Optional height in pixels.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

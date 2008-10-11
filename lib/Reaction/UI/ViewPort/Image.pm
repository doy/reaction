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

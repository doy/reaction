package Reaction::UI::ViewPort::URI;

use Reaction::Class;
use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort';

has uri => ( is => 'rw', isa => 'URI', required => 1);
has display => ( is => 'rw' );

__PACKAGE__->meta->make_immutable;

1;

package Reaction::UI::ViewPort::Collection::Grid::Member::WithActions;

use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort::Collection::Grid::Member';

with 'Reaction::UI::ViewPort::Role::Actions';

__PACKAGE__->meta->make_immutable;


1;

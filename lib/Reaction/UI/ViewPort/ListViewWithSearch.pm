package Reaction::UI::ViewPort::ListViewWithSearch;

use Reaction::Class;
use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort::Collection::Grid';

with 'Reaction::UI::ViewPort::Collection::Role::UseSearchSpec';
with 'Reaction::UI::ViewPort::Collection::Role::Order';
with 'Reaction::UI::ViewPort::Collection::Role::Pager';
with 'Reaction::UI::ViewPort::Role::Actions';

__PACKAGE__->meta->make_immutable;

1;

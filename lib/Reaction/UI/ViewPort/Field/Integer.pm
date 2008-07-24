package Reaction::UI::ViewPort::Field::Integer;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

use namespace::clean -except => [ qw(meta) ];
extends Field;


has '+value' => (isa => 'Int');
__PACKAGE__->meta->make_immutable;


1;

package Reaction::UI::ViewPort::Field::Number;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

use namespace::clean -except => [ qw(meta) ];
extends Field;


has '+value' => (isa => 'Num');
__PACKAGE__->meta->make_immutable;


1;

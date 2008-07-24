package Reaction::UI::ViewPort::Field::Text;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

use namespace::clean -except => [ qw(meta) ];
extends Field;


has '+value' => (isa => 'Str');
__PACKAGE__->meta->make_immutable;


1;

package Reaction::UI::ViewPort::Field::Boolean;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Field';

use namespace::clean -except => [ qw(meta) ];
extends Field;


has '+value' => (isa => 'Bool');

override _empty_string_value => sub { 0 };
__PACKAGE__->meta->make_immutable;


1;

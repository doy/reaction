package Reaction::Meta::Class;

use Moose;
use Reaction::Meta::Attribute;

extends 'Moose::Meta::Class';

with 'Reaction::Role::Meta::Class';

no Moose;

#__PACKAGE__->meta->make_immutable;

1;

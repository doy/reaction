package Reaction::Meta::Class;

use Moose;
use Reaction::Meta::Attribute;

extends 'Moose::Meta::Class';

around initialize => sub {
    my $super = shift;
    my $class = shift;
    my $pkg   = shift;
    $super->($class, $pkg, 'attribute_metaclass' => 'Reaction::Meta::Attribute', @_ );
};


__PACKAGE__->meta->make_immutable;

1;

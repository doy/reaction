package Reaction::Role::Meta::Class;

use Moose::Role;

around initialize => sub {
    my $super = shift;
    my $class = shift;
    my $pkg   = shift;
    $super->($class, $pkg, 'attribute_metaclass' => 'Reaction::Meta::Attribute', @_ );
};

1;

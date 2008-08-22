package Reaction::UI::ViewPort::Action;

use Reaction::Class;
extends 'Reaction::UI::ViewPort::Object::Mutable';

sub BUILD {
  warn "This package is deprecated. please use 'Reaction::UI::ViewPort::Object::Mutable'";
}

__PACKAGE__->meta->make_immutable;

1;

__END__;


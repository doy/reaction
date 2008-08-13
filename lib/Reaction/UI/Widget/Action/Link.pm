package Reaction::UI::Widget::Action::Link;

use Reaction::UI::WidgetClass;

#I want to change this at some point.
use namespace::clean -except => [ qw(meta) ];


before fragment widget {
  arg uri => $_{viewport}->uri;
  arg label => $_{viewport}->label;
};

__PACKAGE__->meta->make_immutable;


1;

__END__;


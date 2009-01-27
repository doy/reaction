package Reaction::UI::Widget::Data;

use Reaction::UI::WidgetClass;
use namespace::clean -except => [qw(meta)];

extends 'Reaction::UI::Widget::Container';

before fragment widget {
  my $data = $_{viewport}->args;
  arg $_ => $data->{$_} for keys %$data;
};

1;

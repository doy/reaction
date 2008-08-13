package Reaction::UI::Widget::Collection::Grid::Member::WithActions;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Collection::Grid::Member';



implements fragment actions {
  render action => over $_{viewport}->actions;
};

implements fragment action {
  render 'viewport';
};

__PACKAGE__->meta->make_immutable;


1;

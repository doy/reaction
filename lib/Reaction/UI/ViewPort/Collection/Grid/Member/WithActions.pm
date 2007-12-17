package Reaction::UI::ViewPort::Collection::Grid::Member::WithActions;

use Reaction::Class;

class WithActions is 'Reaction::UI::ViewPort::Collection::Grid::Member', which {

  does 'Reaction::UI::ViewPort::Role::Actions';

};

1;

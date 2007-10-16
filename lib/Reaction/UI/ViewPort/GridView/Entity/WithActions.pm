package Reaction::UI::ViewPort::GridView::Entity::WithActions;

use Reaction::Class;

class WithActions is 'Reaction::UI::ViewPort::GridView::Entity', which {

  does 'Reaction::UI::ViewPort::GridView::Role::Entity::Actions';

};

1;

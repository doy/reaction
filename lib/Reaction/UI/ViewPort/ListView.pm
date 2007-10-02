package Reaction::UI::ViewPort::ListView;

use Reaction::Class;

class ListView is 'Reaction::UI::ViewPort::GridView', which {

  does 'Reaction::UI::ViewPort::GridView::Role::Order';
  does 'Reaction::UI::ViewPort::GridView::Role::Pager';

};

1;

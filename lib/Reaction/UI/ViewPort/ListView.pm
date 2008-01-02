package Reaction::UI::ViewPort::ListView;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Collection::Grid::Member::WithActions';

class ListView is 'Reaction::UI::ViewPort::Collection::Grid', which {

  does 'Reaction::UI::ViewPort::Collection::Role::Order';
  does 'Reaction::UI::ViewPort::Collection::Role::Pager';
  does 'Reaction::UI::ViewPort::Role::Actions';

  #If I decide that object actions and collection actions should be
  #lumped together i oculd move these into the collection action role
  #ooor we could create a third role that does this, but gah, no?
  implements _build_member_class => as { WithActions };

  #You'se has to goes aways. sorry.
  #if i saved the args as an attribute i could probably get around this....
  implements object_action_count => as {
    my $self = shift;
    for ( @{ $self->members } ) {
      #pickup here, and of to the widget for listview
      return scalar @{ $_->action_prototypes };
    }
  };

};

1;

package Reaction::UI::ViewPort::ListView;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort::Collection::Grid::Member::WithActions';

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort::Collection::Grid';

with 'Reaction::UI::ViewPort::Collection::Role::Order';
with 'Reaction::UI::ViewPort::Collection::Role::Pager';
with 'Reaction::UI::ViewPort::Role::Actions';

#If I decide that object actions and collection actions should be
#lumped together i oculd move these into the collection action role
#ooor we could create a third role that does this, but gah, no?
sub _build_member_class { WithActions };

#You'se has to goes aways. sorry.
#if i saved the args as an attribute i could probably get around this....
sub object_action_count {
  my $self = shift;
  for ( @{ $self->members } ) {
    #pickup here, and of to the widget for listview
    return scalar @{ $_->action_prototypes };
  }
};

__PACKAGE__->meta->make_immutable;


1;

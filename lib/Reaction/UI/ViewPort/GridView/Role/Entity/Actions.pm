package Reaction::UI::ViewPort::GridView::Role::Entity::Actions;

use strict;
use warnings;

use Reaction::Role;
use Reaction::UI::ViewPort::GridView::Action;

role Actions, which {

  has actions => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has action_prototypes => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  implements _build_action_prototypes => as { [] };

  implements _build_actions => as {
    my ($self) = @_;
    my (@act, $i);
    my $ctx = $self->ctx;
    my $obj = $self->object;
    my $loc = $self->location;
    foreach my $proto (@{ $self->action_prototypes }) {
      my $action = Reaction::UI::ViewPort::GridView::Action->new
        (
         ctx      => $ctx,
         target   => $obj,
         location => join('-', $loc, 'action', $i++),
         %$proto,
        );
      push(@act, $action);
    }
    return \@act;
  };

};

1;

package Reaction::UI::ViewPort::Role::Actions;

use Reaction::Role;
use Reaction::UI::ViewPort::Action::Link;

role Actions, which {

  has actions => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  has action_prototypes => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
  implements _build_action_prototypes => as { [] };

  implements _build_actions => as {
    my ($self) = @_;
    my (@act, $i);
    my $ctx = $self->ctx;
    #if i could abstract this vs ->object for row we could eliminate the entity
    #version of this role and just use one for both things. that would be cool.
    my $obj = $self->current_collection;
    my $loc = $self->location;
    foreach my $proto (@{ $self->action_prototypes }) {
      my $action = Reaction::UI::ViewPort::Action::Link->new
        (
         ctx      => $ctx,
         target   => $obj,
         location => join ('-', $loc, 'action', $i++),
         %$proto,
        );
      push(@act, $action);
    }
    return \@act;
  };

};

1;

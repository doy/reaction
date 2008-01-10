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
    my $loc = $self->location;
    foreach my $proto (@{ $self->action_prototypes }) {
      my $action = Reaction::UI::ViewPort::Action::Link->new
        (
         ctx      => $ctx,
         target   => $self->model,
         location => join ('-', $loc, 'action', $i++),
         %$proto,
        );
      push(@act, $action);
    }
    return \@act;
  };

};

1;

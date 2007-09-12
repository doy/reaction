package Reaction::UI::Widget;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort';
use aliased 'Reaction::UI::View';

class Widget which {

  has 'viewport' => (isa => ViewPort, is => 'ro'); # required?
  has 'view' => (isa => View, is => 'ro', required => 1);

  implements 'render' => as {
    my ($self, $rctx) = @_;
    $self->render_widget($rctx, { self => $self });
  };

  implements 'render_viewport' => as {
    my ($self, $rctx, $args) = @_;
    my $vp = $args->{'_'};
    $self->view->render_viewport($rctx, $vp);
  };

};

1;

=head1 NAME

Reaction::UI::Widget

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

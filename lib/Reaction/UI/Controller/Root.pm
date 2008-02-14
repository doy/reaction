package Reaction::UI::Controller::Root;

use base qw/Reaction::UI::Controller/;
use Reaction::Class;
use Reaction::UI::Window;

__PACKAGE__->config(
  view_name => 'XHTML',
  content_type => 'text/html',
);

has 'view_name' => (isa => 'Str', is => 'rw', required => 1);
has 'content_type' => (isa => 'Str', is => 'rw', required => 1);
has 'window_title' => (
  isa => 'Str', is => 'rw', predicate => 'has_window_title'
);

sub begin :Private {
  my ($self, $ctx) = @_;
  $ctx->stash(
    window => Reaction::UI::Window->new(
                ctx => $ctx,
                view_name => $self->view_name,
                content_type => $self->content_type,
                ($self->has_window_title
                  ? (title => $self->window_title)
                  : ()),
              )
  );
  $ctx->stash(focus_stack => $ctx->stash->{window}->focus_stack);
}

sub end :Private {
  my ($self, $ctx) = @_;
  $ctx->stash->{window}->flush;
}

sub error_404 :Private {
  my ($self, $c) = @_;
  $c->res->body("Error 404: Not Found");
  $c->res->status(404);
  $c->res->content_type('text/plain');
}

sub error_403 :Private {
  my ($self, $c) = @_;
  $c->res->body("Error 403: Forbidden");
  $c->res->status(403);
  $c->res->content_type('text/plain');
}

1;

=head1 NAME

Reaction::UI::Controller::Root - Base component for the Root Controller

=head1 SYNOPSIS

  package MyApp::Controller::Root;
  use base 'Reaction::UI::Controller::Root';

  __PACKAGE__->config(
    view_name => 'Site',
    window_title => 'Reaction Test App',
    namespace => ''
  );

  # Create UI elements:
  $c->stash->{focus_stack}->push_viewport('Reaction::UI::ViewPort');

  # Access the window title in a template:
  [% window.title %]

=head1 DESCRIPTION

Using this module as a base component for your L<Catalyst> Root
Controller provides automatic creation of a L<Reaction::UI::Window>
object containing an empty L<Reaction::UI::FocusStack> for your UI
elements. The stack is also resolved and rendered for you in the
C<end> action.

At the C<begin> of each request, a L<Reaction::UI::Window> object is
created using the configured L</view_name>, L</content_type> and
L</window_title>. These thus should be directly changed on the stashed
window object at runtime, if needed.

=head1 METHODS

=head2 view_name

=over

=item Arguments: $viewname?

=back

Set or retrieve the classname of the view used to render the UI. Can
also be set by a call to config. Defaults to 'XHTML'.

=head2 content_type

=over

=item Arguments: $contenttype?

=back

Set or retrieve the content type of the page created. Can also be set
by a call to config or in a config file. Defaults to 'text/html'.

=head2 window_title

=over

=item Arguments: $windowtitle?

=back

Set or retrieve the title of the page created. Can also be set by a
call to config or in a config file. No default.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

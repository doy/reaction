package Reaction::UI::Window;

use Reaction::Class;
use Reaction::UI::FocusStack;

class Window which {

  has ctx => (isa => 'Catalyst', is => 'ro', required => 1);
  has view_name => (isa => 'Str', is => 'ro', lazy_fail => 1);
  has content_type => (isa => 'Str', is => 'ro', lazy_fail => 1);
  has title => (isa => 'Str', is => 'rw', default => sub { 'Untitled window' });
  has view => (
    # XXX compile failure because the Catalyst::View constraint would be
    # auto-generated which doesn't work with unions. ::Types::Catalyst needed.
    #isa => 'Catalyst::View|Reaction::UI::View',
    isa => 'Object', is => 'ro', lazy_build => 1
  );
  has focus_stack => (
    isa => 'Reaction::UI::FocusStack',
    is => 'ro', required => 1,
    default => sub { Reaction::UI::FocusStack->new },
  );
  
  implements build_view => as {
    my ($self) = @_;
    return $self->ctx->view($self->view_name);
  };
  
  implements flush => as {
    my ($self) = @_;
    $self->flush_events;
    $self->flush_view;
  };
  
  implements flush_events => as {
    my ($self) = @_;
    my $ctx = $self->ctx;
    foreach my $type (qw/query body/) {
      my $meth = "${type}_parameters";
      my $param_hash = $ctx->req->$meth;
      $self->focus_stack->apply_events($ctx, $param_hash);
    }
  };
  
  implements flush_view => as {
    my ($self) = @_;
    return if $self->ctx->res->status =~ /^3/ || length($self->ctx->res->body);
    $self->ctx->res->body(
      $self->view->render_window($self)
    );
    $self->ctx->res->content_type($self->content_type);
  };

  # required by old Renderer::XHTML
  
  implements render_viewport => as {
    my ($self, $vp) = @_;
    return unless $vp;
    return $self->view->render_viewport($self, $vp);
  };

};

1;

=head1 NAME

Reaction::UI::Window - Container for rendering the UI elements in

=head1 SYNOPSIS

  my $window = Reaction::UI::Window->new(
    ctx => $ctx,
    view_name => $view_name,
    content_type => $content_type,
    title => $window_title,
  );

  # More commonly, as Reaction::UI::RootController creates one for you:
  my $window = $ctx->stash->{window};

  # Resolve current events and render the view of the UI 
  #  elements of this Window:
  # This is called by the end action of Reaction::UI::RootController
  $window->flush();

  # Resolve current events:
  $window->flush_events();

  # Render the top ViewPort in the FocusStack of this Window:
  $window->flush_view();

  # Render a particular ViewPort:
  $window->render_viewport($viewport);

  # Or in a template:
  [% window.render_viewport(self.inner) %]

  # Add a ViewPort to the UI:
  $window->focus_stack->push_viewport('Reaction::UI::ViewPort');

=head1 DESCRIPTION

A Window object is created and stored in the stash by
L<Reaction::UI::RootController>, it is used to contain all the
elements (ViewPorts) that make up the UI. The Window is rendered in
the end action of the RootController to make up the page.

To add L<ViewPorts|Reaction::UI::ViewPort> to the stack, read the
L<Reaction::UI::FocusStack> and L<Reaction::UI::ViewPort> documentation.

Several Window attributes are set by
L<Reaction::UI::RootController/begin> when a new Window is created,
these are as follows:

=over

=item ctx

The current L<Catalyst> context object is set.

=item view_name

The view_name is set from the L<Reaction::UI::RootController> attributes.

=item content_type

The content_type is set from the L<Reaction::UI::RootController> attributes.

=item window_title

The window_title is set from the L<Reaction::UI::RootController> attributes.

=back

=head1 METHODS

=head2 ctx

=over

=item Arguments: none

=back

Retrieve the current L<Catalyst> context object.

=head2 view_name

=over

=item Arguments: none

=back

Retrieve the name of the L<Catalyst::View> component used to render
this Window. If this has not been set, rendering the Window will fail.

=head2 content_type

=over

=item Arguments: none

=back

Retrieve the content_type for the page. If this has not been set,
rendering the Window will fail.

=head2 title

=over

=item Arguments: $title?

=back

  [% window.title %]

Retrieve the title of this page, if not set, it will default to
"Untitled window".

=head2 view

=over

=item Arguments: none

=back

Retrieve the L<Catalyst::View> instance, this can be set, or will be
instantiated using the L<view_name> class.

=head2 focus_stack

=over

=item Arguments: none

=back

  $window->focus_stack->push_viewport('Reaction::UI::ViewPort');

Retrieve the L<stack|Reaction::UI::FocusStack> of
L<ViewPorts|Reaction::UI::ViewPorts> that contains all the UI elements
for this Window. Use L<Reaction::UI::FocusStack/push_viewport> on this
to create more elements. An empty FocusStack is created by the
RootController when the Window is created.

=head2 render_viewport

=over

=item Arguments: $viewport

=back

  $window->render_viewport($viewport);

  [% window.render_viewport(self.inner) %]

Calls render on the L<view> object used by this Window. The following
arguments are given:

=over

=item ctx

The L<Catalyst> context object.

=item self

The ViewPort object to be rendered.

=item window

The Window object.

=item type

The string that describes the layout from L<Reaction::UI::ViewPort/layout>.

=back

=head2 flush

=over

=item Arguments: none

=back

Synchronize the current events with all the L<Reaction::UI::ViewPort>
objects in the UI, then render the root ViewPort. This is called for
you by L<Reaction::UI::RootController/end>.

=head2 flush_events

=over

=item Arguments: none

=back

Resolves all the current events, first the query parameters then the
body parameters, with all the L<Reaction::UI::ViewPort> objects in the
UI. This calls L<Reaction::UI::FocusStack/apply_events>. This method
is called by L<flush>.

=head2 flush_view

=over

=item Arguments: none

=back

Renders the page into the L<Catalyst::Response> body, unless the
response status is already set to 3xx, or the body has already been
filled. This calls L<render_viewport> with the root
L<Reaction::UI::ViewPort> from the L<focus_stack>. This method is
called by L<flush>.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

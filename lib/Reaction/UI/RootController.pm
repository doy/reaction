package Reaction::UI::RootController;

use base qw/Reaction::UI::Controller/;
use Reaction::Class;
use Reaction::UI::Window;

__PACKAGE__->config(
  view_name => 'XHTML',
  content_type => 'text/html',
);

has 'view_name' => (isa => 'Str', is => 'rw');
has 'content_type' => (isa => 'Str', is => 'rw');
has 'window_title' => (isa => 'Str', is => 'rw');

sub begin :Private {
  my ($self, $ctx) = @_;
  my $window :Stashed = Reaction::UI::Window->new(
                          ctx => $ctx,
                          view_name => $self->view_name,
                          content_type => $self->content_type,
                          title => $self->window_title,
                        );
  my $focus_stack :Stashed = $window->focus_stack;
}

sub end :Private {
  my $window :Stashed;
  $window->flush;
}

1;

=head1 NAME

Reaction::UI::RootController - Base component for the Root Controller

=head1 SYNOPSIS

  package MyApp::Controller::Root;
  use base 'Reaction::UI::RootController';

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

=head1 METHODS

=head2 view_name

=over

=item Arguments: $viewname?

=back

Set or retrieve the classname of the view used to render the UI.

=head2 content_type

=over

=item Arguments: $contenttype?

=back

Set or retrieve the content type of the page created.

=head2 window_title

=over

=item Arguments: $windowtitle?

=back

Set or retrieve the title of the page created.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

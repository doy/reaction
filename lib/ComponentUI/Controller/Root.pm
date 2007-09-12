package ComponentUI::Controller::Root;

use strict;
use warnings;
use base 'Reaction::UI::RootController';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
  view_name => 'XHTML',
  window_title => 'Reaction Test App',
  content_type => 'text/html',
  namespace => '',
);

sub base :Chained('/') :PathPart('') :CaptureArgs(0) {
  my ($self, $c) = @_;
  $self->push_viewport(ViewPort, layout => 'xhtml');
}

sub root :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;
  $self->push_viewport(ViewPort, layout => 'index');
}

1;

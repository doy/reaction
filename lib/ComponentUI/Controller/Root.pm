package ComponentUI::Controller::Root;

use strict;
use warnings;
use base 'Reaction::UI::Controller::Root';
use Reaction::Class;

use aliased 'Reaction::UI::ViewPort';
use aliased 'Reaction::UI::ViewPort::SiteLayout';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
  view_name => 'Site',
  window_title => 'Reaction Test App',
  namespace => ''
);

sub base :Chained('/') :PathPart('') :CaptureArgs(0) {
  my ($self, $c) = @_;
  $self->push_viewport(SiteLayout,
    title => 'ComponentUI test title',
    static_base_uri => "${\$c->uri_for('/static')}",
  );
}

sub root :Chained('base') :PathPart('') :Args(0) {
  my ($self, $c) = @_;
  $self->push_viewport(ViewPort, layout => 'index');
}

sub static :Chained('base') :PathPart('static') :Args {
  my ($self, $c, @args) = @_;
  return if $c->stash->{window}->view->serve_static_file($c, \@args);
  $c->forward('error_404');
}

sub error_404 :Private {
  my ($self, $c) = @_;
  $c->res->body("Error 404");
  $c->res->status(404);
}

1;

package Reaction::UI::Renderer::XHTML;

use strict;
use base qw/Catalyst::View::TT Reaction::Object/;
use Reaction::Class;

use HTML::Entities;

__PACKAGE__->config({
  CATALYST_VAR => 'ctx',
  RECURSION => 1,
});

sub render_window {
  my ($self, $window) = @_;
  my $root_vp = $window->focus_stack->vp_head;
  confess "Can't flush view for window with empty focus stack"
    unless defined($root_vp);
  $self->render_viewport($window, $root_vp);
}

sub render_viewport {
  my ($self, $window, $vp) = @_;
  my $ctx = $window->ctx;
  my %args = (
    self => $vp,
    ctx => $ctx,
    window => $window,
    type => $vp->layout
  );
  unless (length $args{type}) {
    my $type = (split('::', ref($vp)))[-1];
    $args{type} = lc($type);
  }
  return $self->render($ctx, 'component', \%args);
}

around 'render' => sub {
  my $super = shift;
  my ($self,$args) = @_[0,3];
  local $self->template->{SERVICE}{CONTEXT}{BLKSTACK};
  local $self->template->{SERVICE}{CONTEXT}{BLOCKS};
  $args->{process_attrs} = \&process_attrs;
  return $super->(@_);
};

sub process_attrs{
    my $attrs = shift;
    return $attrs unless ref $attrs eq 'HASH';

    my @processed_attrs;
    while( my($k,$v) = each(%$attrs) ){
        my $enc_v = $v;
        next if ($enc_v eq "");
        if ($k eq 'class' && ref $v eq 'ARRAY'){
            $enc_v = join ' ', map { encode_entities($_) } @$v;
        } elsif ($k eq 'style' && ref $v eq 'HASH'){
            $enc_v = join '; ', map{ "${_}: ".encode_entities($v->{$_}) } keys %{$v};
        }
        push(@processed_attrs, "${k}=\"${enc_v}\"");
    }

    return ' '.join ' ', @processed_attrs if (scalar(@processed_attrs) > 0);
    return;
}

1;

=head1 NAME

Reaction::UI::Renderer::XHTML

=head1 DESCRIPTION

=head1 METHODS

=head2 render

=head2 process_attrs

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

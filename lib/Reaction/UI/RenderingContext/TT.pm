package Reaction::UI::RenderingContext::TT;

use Reaction::Class;
use aliased 'Reaction::UI::RenderingContext';
use aliased 'Template::View';

class TT is RenderingContext, which {

  has 'tt_view' => ( is => 'ro', required => 1, isa => View);

  has 'iter_class' => (
    is => 'ro', required => 1,
    default => sub { 'Reaction::UI::Renderer::TT::Iter'; },
  );

  implements 'render' => as {
    my ($self, $fname, $args) = @_;
  
    # foreach non-_ prefixed key in the args
    # build a subref for this key that passes self so the generator has a
    # rendering context when [% key %] is evaluated by TT as $val->()
    # (assuming it's a subref - if not just pass through)
  
    my $tt_args = {
      map {
        my $arg = $args->{$_};
        ($_ => (ref $arg eq 'CODE' ? sub { $arg->($self) } : $arg))
      } grep { !/^_/ } keys %$args
    };
  
    # if there's an _ key that's our current topic (decalarative syntax
    # sees $_ as $_{_}) so build an iterator around it.
  
    # There's possibly a case for making everything an iterator but I think
    # any fragment should only have a single multiple arg
  
    # we also create a 'pos' shortcut to content.pos for brevity
  
    if (my $topic = $args->{_}) {
      my $iter = $self->iter_class->new(
        $topic, $self
      );
      $tt_args->{content} = $iter;
      $tt_args->{pos} = sub { $iter->pos };
    }
    $self->tt_view->include($fname, $tt_args);
  };

};
  
package Reaction::UI::Renderer::TT::Iter;

use overload (
  q{""} => 'stringify',
  fallback => 1
);

sub pos { shift->{pos} }

sub new {
  my ($class, $cr, $rctx) = @_;
  bless({ rctx => $rctx, cr => $cr, pos => 0 }, $class);
}

sub next {
  my $self = shift;
  $self->{pos}++;
  my $next = $self->{cr}->();
  return unless $next;
  return sub { $next->($self->{rctx}) };
}

sub all {
  my $self = shift;
  my @all;
  while (my $e = $self->next) {
    push(@all, $e);
  }
  \@all;
}

sub stringify {
  my $self = shift;
  my $res = '';
  foreach my $e (@{$self->all}) {
    $res .= $e->();
  }
  $res;
}

1;

package Reaction::UI::View::TT;

use Reaction::Class;
use aliased 'Reaction::UI::View';
use Template;

class TT is View, which {

  has '_tt' => (isa => 'Template', is => 'rw', lazy_fail => 1);

  implements 'BUILD' => as {
    my ($self, $args) = @_;
    my $tt_args = $args->{tt}||{};
    $self->_tt(Template->new($tt_args));
  };

  overrides 'layout_set_args_for' => sub {
    my ($self) = @_;
    return (super(), tt_object => $self->_tt);
  };

  overrides 'rendering_context_args_for' => sub {
    my ($self, %args) = @_;
    return (super(), tt_view => $args{layouts}->tt_view);
  };

  implements 'serve_static_file' => as {
    my ($self, $c, $args) = @_;
    foreach my $path (@{$self->search_path_for_type('web')}) {
      my $cand = $path->file(@$args);
      if ($cand->stat) {
        $c->serve_static_file($cand);
        return 1;
      }
    }
    return 0;
  };

};

1;

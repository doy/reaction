package Reaction::UI::View;

use Reaction::Class;

# declaring dependencies

use Reaction::UI::LayoutSet;
use Reaction::UI::RenderingContext;

class View which {

  has '_layout_set_cache' => (is => 'ro', default => sub { {} });

  has 'app' => (is => 'ro', required => 1);

  has 'skin_name' => (is => 'ro', required => 1);

  has 'layout_set_class' => (is => 'ro', lazy_build => 1);

  has 'rendering_context_class' => (is => 'ro', lazy_build => 1);

  implements 'COMPONENT' => as {
    my ($class, $app, $args) = @_;
    return $class->new(%{$args||{}}, app => $app);
  };

  implements 'render_window' => as {
    my ($self, $window) = @_;
    my $root_vp = $window->focus_stack->vp_head;
    $self->render_viewport(undef, $root_vp);
  };

  implements 'render_viewport' => as {
    my ($self, $outer_rctx, $vp) = @_;
    my $layout_set = $self->layout_set_for($vp);
    my $rctx = $self->create_rendering_context(
      layouts => $layout_set,
      outer => $outer_rctx,
    );
    my $widget = $self->widget_for($vp, $layout_set);
    $widget->render($rctx);
  };

  implements 'widget_for' => as {
    my ($self, $vp, $layout_set) = @_;
    return $self->widget_class_for($layout_set)
                ->new(view => $self, viewport => $vp);
  };

  implements 'widget_class_for' => as {
    my ($self, $layout_set) = @_;
    my $base = ref($self);
    my $tail = $layout_set->widget_type;
    my $class = join('::', $base, 'Widget', $tail);
    Class::MOP::load_class($class);
    return $class;
  };

  implements 'layout_set_for' => as {
    my ($self, $vp) = @_;
    my $lset_name = eval { $vp->layout };
    confess "Couldn't call layout method on \$vp arg ${vp}: $@" if $@;
    unless (length($lset_name)) {
      my $last = (split('::',ref($vp)))[-1];
      $lset_name = join('_', map { lc($_) } split(/(?=[A-Z])/, $last));
    }
    my $cache = $self->_layout_set_cache;
    return $cache->{$lset_name} ||= $self->create_layout_set($lset_name);
  };

  implements 'create_layout_set' => as {
    my ($self, $name) = @_;
    return $self->layout_set_class->new(
             $self->layout_set_args_for($name),
           );
  };

  implements 'find_related_class' => as {
    my ($self, $rel) = @_;
    my $own_class = ref($self)||$self;
    confess View." is abstract, you must subclass it" if $own_class eq View;
    foreach my $super ($own_class->meta->class_precedence_list) {
      next if $super eq View;
      if ($super =~ /::View::/) {
        (my $class = $super) =~ s/::View::/::${rel}::/;
        if (eval { Class::MOP::load_class($class) }) {
          return $class;
        }
      }
    }
    confess "Unable to find related ${rel} class for ${own_class}";
  };

  implements 'build_layout_set_class' => as {
    my ($self) = @_;
    return $self->find_related_class('LayoutSet');
  };

  implements 'layout_set_args_for' => as {
    my ($self, $name) = @_;
    return (name => $name, search_path => $self->layout_search_path);
  };

  implements 'layout_search_path' => as {
    my ($self) = @_;
    return $self->search_path_for_type('layout');
  };

  implements 'search_path_for_type' => as {
    my ($self, $type) = @_;
    return [ $self->app->path_to('share','skin',$self->skin_name,$type) ];
  };

  implements 'create_rendering_context' => as {
    my ($self, @args) = @_;
    return $self->rendering_context_class->new(
             $self->rendering_context_args_for(@args),
             @args,
           );
  };

  implements 'build_rendering_context_class' => as {
    my ($self) = @_;
    return $self->find_related_class('RenderingContext');
  };

  implements 'rendering_context_args_for' => as {
    return ();
  };

};

1;

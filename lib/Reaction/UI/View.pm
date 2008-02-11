package Reaction::UI::View;

use Reaction::Class;

# declaring dependencies
use Reaction::UI::LayoutSet;
use Reaction::UI::RenderingContext;
use aliased 'Reaction::UI::Skin';
use aliased 'Path::Class::Dir';

class View which {

  has '_widget_cache' => (is => 'ro', default => sub { {} });

  has '_layout_set_cache' => (is => 'ro', default => sub { {} });

  has 'app' => (is => 'ro', required => 1);

  has 'skin_name' => (is => 'ro', required => 1);

  has 'skin' => (
    is => 'ro', lazy_build => 1,
    handles => [ qw(create_layout_set search_path_for_type) ]
  );

  has 'layout_set_class' => (is => 'ro', lazy_build => 1);

  has 'rendering_context_class' => (is => 'ro', lazy_build => 1);

  implements '_build_layout_set_class' => as {
    my ($self) = @_;
    return $self->find_related_class('LayoutSet');
  };

  implements '_build_rendering_context_class' => as {
    my ($self) = @_;
    return $self->find_related_class('RenderingContext');
  };

  implements '_build_skin' => as {
    my ($self) = @_;
    Skin->new(
      name => $self->skin_name, view => $self,
      # path_to returns a File, not a Dir. Thanks, Catalyst.
      skin_base_dir => Dir->new($self->app->path_to('share', 'skin')),
    );
  };

  implements 'COMPONENT' => as {
    my ($class, $app, $args) = @_;
    return $class->new(%{$args||{}}, app => $app);
  };

  implements 'render_window' => as {
    my ($self, $window) = @_;
    my $root_vp = $window->focus_stack->vp_head;
    my $rctx = $self->create_rendering_context;
    my ($widget, $args) = $self->render_viewport_args($root_vp);
    $widget->render(widget => $rctx, $args);
  };

  implements 'render_viewport_args' => as {
    my ($self, $vp) = @_;
    my $layout_set = $self->layout_set_for($vp);
    my $widget = $self->widget_for($vp, $layout_set);
    return ($widget, { viewport => $vp });
  };

  implements 'widget_for' => as {
    my ($self, $vp, $layout_set) = @_;
    return
      $self->_widget_cache->{$layout_set->name}
        ||= $layout_set->widget_class
                       ->new(
                           view => $self, layout_set => $layout_set
                         );
  };

  implements 'layout_set_for' => as {
    my ($self, $vp) = @_;
    #print STDERR "Getting layoutset for VP ".(ref($vp) || "SC:".$vp)."\n";
    my $lset_name = eval { $vp->layout };
    confess "Couldn't call layout method on \$vp arg ${vp}: $@" if $@;
    unless (length($lset_name)) {
      my $vp_class = ref($vp) || $vp;
      my ($last) = ($vp_class =~ /.*(?:::ViewPort::)(.+?)$/);
      my @fragments = split('::', $last);
      $_ = join("_", split(/(?=[A-Z])/, $_)) for @fragments;
      $lset_name = lc(join('/', @fragments));
      #print STDERR "--- $vp_class is rendered as $lset_name\n";
    }
    my $cache = $self->_layout_set_cache;
    return $cache->{$lset_name} ||= $self->create_layout_set($lset_name);
  };

  implements 'layout_set_file_extension' => as {
    confess View." is abstract, you must subclass it";
  };

  implements 'find_related_class' => as {
    my ($self, $rel) = @_;
    my $own_class = ref($self) || $self;
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

  implements 'create_rendering_context' => as {
    my ($self, @args) = @_;
    return $self->rendering_context_class->new(
             $self->rendering_context_args_for(@args),
             @args,
           );
  };

  implements 'rendering_context_args_for' => as {
    return ();
  };

  implements 'layout_set_args_for' => as {
    return ();
  };

};

1;

package Reaction::UI::View;

use Reaction::Class;

# declaring dependencies
use Reaction::UI::LayoutSet;
use Reaction::UI::RenderingContext;

class View which {

  has '_layout_set_cache'   => (is => 'ro', default => sub { {} });
  has '_widget_class_cache' => (is => 'ro', default => sub { {} });
  has '_widget_cache' => (is => 'ro', default => sub { {} });

  has 'app' => (is => 'ro', required => 1);

  has 'skin_name' => (is => 'ro', required => 1);

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

  implements 'COMPONENT' => as {
    my ($class, $app, $args) = @_;
    return $class->new(%{$args||{}}, app => $app);
  };

  sub BUILD{
    my $self = shift;
    my $skin_name = $self->skin_name;
    #XXX i guess we will add the path to installed reaction templates here
    my $skin_path = $self->app->path_to('share','skin',$skin_name);
    confess("'${skin_path}' is not a valid path for skin '${skin_name}'")
      unless -d $skin_path;
  }

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

  implements 'widget_class_for' => as {
    my ($self, $layout_set) = @_;
    my $base = $self->blessed;
    my $tail = $layout_set->widget_type;
    my $lset_name = $layout_set->name;
    # eventually more stuff will go here i guess?
    my $app_name = ref $self->app || $self->app;
    my $cache = $self->_widget_class_cache;
    return $cache->{ $lset_name } if exists $cache->{ $lset_name };

    my @search_path = ($base, $app_name, 'Reaction::UI');
    my @haystack    = map { join '::', $_, 'Widget', $tail } @search_path;
    for my $class (@haystack){
      #here we should throw if exits and error instead of eating the error
      #only next when !exists
      eval { Class::MOP::load_class($class) };
      #$@ ? next : return  $class;
      #warn "Loaded ${class}" unless $@;
      $@ ? next : return $cache->{ $lset_name } = $class;
    }
    confess "Couldn't load widget '$tail': tried: @haystack";
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

  implements 'create_layout_set' => as {
    my ($self, $name) = @_;
    return $self->layout_set_class->new(
             $self->layout_set_args_for($name),
           );
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

  implements 'layout_set_args_for' => as {
    my ($self, $name) = @_;
    return (
      name => $name,
      search_path => $self->layout_search_path,
      view => $self,
    );
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

  implements 'rendering_context_args_for' => as {
    return ();
  };

};

1;

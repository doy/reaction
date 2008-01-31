package Reaction::UI::Skin;

use Reaction::Class;

# declaring dependencies
use Reaction::UI::LayoutSet;
use Reaction::UI::RenderingContext;
use File::ShareDir;

use aliased 'Path::Class::Dir';

class Skin which {

  has '_layout_set_cache'   => (is => 'ro', default => sub { {} });
  has '_widget_class_cache'   => (is => 'ro', default => sub { {} });

  has 'name' => (is => 'ro', isa => 'Str', required => 1);
  has 'skin_dir' => (is => 'rw', isa => Dir, lazy_fail => 1);

  has 'widget_search_path' => (
    is => 'rw', isa => 'ArrayRef', requred => 1, default => sub { [] }
  );

  has 'view' => (
    is => 'ro', required => 1, weak_ref => 1,
    handles => [ qw(layout_set_class) ],
  );

  has 'super' => (
    is => 'rw', isa => Skin, required => 0, predicate => 'has_super',
  );

  sub BUILD {
    my ($self, $args) = @_;
    $self->_find_skin_dir($args);
    $self->_load_skin_config($args);
  }

  implements '_find_skin_dir' => as {
    my ($self, $args) = @_;
    my $skin_name = $self->name;
    if ($skin_name =~ s!^/(.*?)/!!) {
      my $dist = $1;
      $args->{skin_base_dir} =
        Dir->new(File::ShareDir::dist_dir($dist))
           ->subdir('skin');
    }
    my $base = $args->{skin_base_dir}->subdir($skin_name);
    confess "No such skin base directory ${base}"
      unless -d $base;
    $self->skin_dir($base);
  };

  implements '_load_skin_config' => as {
    my ($self, $args) = @_;
    my $base = $self->skin_dir;
    my $lst = sub { (ref $_[0] eq 'ARRAY') ? $_[0] : [$_[0]] };
    my @files = (
      $args->{skin_base_dir}->file('defaults.conf'), $base->file('skin.conf')
    );
    # we get [ { $file => $conf }, ... ]
    my %cfg = (map { %{(values %{$_})[0]} }
                @{Config::Any->load_files({
                  files => [ grep { -e $_ } @files ],
                  use_ext => 1,
                })}
              );
    if (my $super_name = $cfg{extends}) {
      my $super = $self->new(
        name => $super_name,
        view => $self->view,
        skin_base_dir => $args->{skin_base_dir},
      );
      $self->super($super);
    }
    if (exists $cfg{widget_search_path}) {
      $self->widget_search_path($lst->($cfg{widget_search_path}));
    } else {
      confess "No widget_search_path in defaults.conf or skin.conf"
              ." and no search path provided from super skin"
        unless $self->full_widget_search_path;
    }
  }

  implements 'create_layout_set' => as {
    my ($self, $name) = @_;
    if (my $path = $self->layout_path_for($name)) {
      return $self->layout_set_class->new(
               $self->layout_set_args_for($name),
               source_file => $path,
             );
    }
    if ($self->has_super) {
      return $self->super->create_layout_set($name);
    }
    confess "Couldn't find layout set file for ${name}";
  };

  implements 'layout_set_args_for' => as {
    my ($self, $name) = @_;
    return (
      name => $name,
      skin => $self,
      ($self->has_super ? (next_skin => $self->super) : ()),
      $self->view->layout_set_args_for($name),
    );
  };

  implements 'layout_path_for' => as {
    my ($self, $layout) = @_;
    my $file_name = join(
      '.', $layout, $self->view->layout_set_file_extension
    );
    my $path = $self->our_path_for_type('layout')
                    ->file($file_name);
    return (-e $path ? $path : undef);
  };

  implements 'search_path_for_type' => as {
    my ($self, $type) = @_;
    return [
      $self->our_path_for_type($type),
      ($self->has_super
        ? @{$self->super->search_path_for_type($type)}
        : ()
      )
    ];
  };

  implements 'our_path_for_type' => as {
    my ($self, $type) = @_;
    return $self->skin_dir->subdir($type)
  };

  implements 'full_widget_search_path' => as {
    my ($self) = @_;
    return (
      @{$self->widget_search_path},
      ($self->has_super ? $self->super->full_widget_search_path : ())
    );
  };

  implements 'widget_class_for' => as {
    my ($self, $layout_set) = @_;
    my $base = $self->blessed;
    my $widget_type = $layout_set->widget_type;
    return $self->_widget_class_cache->{$widget_type} ||= do {

      my @search_path = $self->full_widget_search_path;
      my @haystack = map {join('::', $_, $widget_type)} @search_path;

      foreach my $class (@haystack) {
        #if the class is already loaded skip the call to Installed etc.
        return $class if Class::MOP::is_class_loaded($class);
        next unless Class::Inspector->installed($class);

        my $ok = eval { Class::MOP::load_class($class) };
        confess("Failed to load widget '${class}': $@") if $@;
        return $class;
      }
      confess "Couldn't locate widget '${widget_type}' for layout "
        ."'${\$layout_set->name}': tried: ".join(", ", @haystack);
    };
  };

};

1;

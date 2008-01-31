package Reaction::UI::Skin;

use Reaction::Class;

# declaring dependencies
use Reaction::UI::LayoutSet;
use Reaction::UI::RenderingContext;

use aliased 'Path::Class::Dir';

class Skin which {

  has '_layout_set_cache'   => (is => 'ro', default => sub { {} });

  has 'skin_base_path' => (is => 'ro', isa => Dir, required => 1);

  has 'widget_search_path' => (is => 'rw', isa => 'ArrayRef', lazy_fail => 1);

  has 'view' => (
    is => 'ro', required => 1, weak_ref => 1,
    handles => [ qw(layout_set_class widget_class_for) ],
  );

  has 'super' => (
    is => 'rw', isa => Skin, required => 0, predicate => 'has_super',
  );

  sub BUILD {
    my ($self) = @_;
    $self->_load_skin_config;
  }

  implements '_load_skin_config' => as {
    my ($self) = @_;
    my $base = $self->skin_base_path;
    confess "No such skin base directory ${base}"
      unless -d $base;
    my $lst = sub { (ref $_[0] eq 'ARRAY') ? $_[0]: [$_[0]] };
    my @files = (
      $base->parent->file('defaults.conf'), $base->file('skin.conf')
    );
    # we get [ { $file => $conf }, ... ]
    my %cfg = (map { %{(values %{$_})[0]} }
                @{Config::Any->load_files({
                  files => [ grep { -e $_ } @files ],
                  use_ext => 1,
                })}
              );
    if (my $super_name = $cfg{extends}) {
      my $super_dir = $base->parent->subdir($super_name);
      my $super = $self->new(
        view => $self->view, skin_base_path => $super_dir
      );
      $self->super($super);
    }
    if (exists $cfg{widget_search_path}) {
      $self->widget_search_path($lst->($cfg{widget_search_path}));
    } else {
      confess "No widget_search_path in defaults.conf or skin.conf";
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
    return $self->skin_base_path->subdir($type)
  };

};

1;

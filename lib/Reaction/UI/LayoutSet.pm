package Reaction::UI::LayoutSet;

use Reaction::Class;
use File::Spec;

class LayoutSet which {

  has 'layouts' => (is => 'ro', default => sub { {} });

  has 'name' => (is => 'ro', required => 1);

  has 'source_file' => (is => 'ro', required => 1);

  has 'widget_class' => (
    is => 'rw', lazy_fail => 1, predicate => 'has_widget_class'
  );

  has 'widget_type' => (is => 'rw', lazy_build => 1);

  has 'super' => (is => 'rw', predicate => 'has_super');

  implements 'BUILD' => as {
    my ($self, $args) = @_;
    my @path = @{$args->{search_path}||[]};
    confess "No view object provided" unless $args->{view};
    confess "No skin object provided" unless $args->{skin};
    $self->_load_file($self->source_file, $args);
    unless ($self->has_widget_class) {
      $self->widget_class($args->{view}->widget_class_for($self));
    }
  };

  implements 'widget_order_for' => as {
    my ($self, $name) = @_;
    return (
      ($self->has_layout($name)
        ? ([ $self->widget_class, $self ]) #;
        : ()),
      ($self->has_super
        ? ($self->super->widget_order_for($name))
        : ()),
    );
  };

  implements 'layout_names' => as {
    my ($self) = @_;
    my %seen;
    return [
      grep { !$seen{$_}++ }
        keys %{shift->layouts},
        ($self->has_super
          ? (@{$self->super->layout_names})
          : ())
    ];
  };

  implements 'has_layout' => as { exists $_[0]->layouts->{$_[1]} };

  implements '_load_file' => as {
    my ($self, $file, $build_args) = @_;
    my $data = $file->slurp;
    my $layouts = $self->layouts;
    # cheesy match for "=for layout name ... =something"
    # final split group also handles last in file, (?==) is lookahead
    # assertion for '=' so "=for layout name1 ... =for layout name2"
    # doesn't have the match pos go past the latter = and lose name2
    while ($data =~ m/=(.*?)\n(.*?)(?:\n(?==)|$)/sg) {
      my ($data, $text) = ($1, $2);
      if ($data =~ /^for layout (\S+)/) {
        my $fname = $1;
        $text =~ s/^(?:\s*\r?\n)+//; #remove leading empty lines
        $text =~ s/[\s\r\n]+$//;     #remove trailing whitespace
        $layouts->{$fname} = $text;
      } elsif ($data =~ /^extends (\S+)/) {
        my $super_name = $1;
        $self->super($build_args->{skin}->create_layout_set($super_name))
      } elsif ($data =~ /^widget (\S+)/) {
        my $widget_type = $1;
        $self->widget_type($1);
      } elsif ($data =~ /^cut/) {
        # no-op
      } else {
        confess "Unparseable directive ${data}";
      }
    }
  };

  implements '_build_widget_type' => as {
    my ($self) = @_;
    my $widget = join('',   map { ucfirst($_) } split('_', $self->name));
    $widget    = join('::', map { ucfirst($_) } split('/', $widget));

    #print STDERR "--- ", $self->name, " maps to widget $widget \n";

    return $widget;
  };

};

1;

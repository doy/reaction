package Reaction::UI::LayoutSet;

use Reaction::Class;
use File::Spec;

class LayoutSet which {

  has 'fragments' => (is => 'ro', default => sub { {} });

  has 'name' => (is => 'ro', required => 1);

  has 'source_file' => (is => 'rw', lazy_fail => 1);

  implements 'BUILD' => as {
    my ($self, $args) = @_;
    my @path = @{$args->{search_path}||[]};
    confess "No search_path provided" unless @path;
    my $found;
    SEARCH: foreach my $path (@path) {
      my $cand = $path->file($self->name);
      if ($cand->stat) {
        $self->_load_file($cand);
        $found = 1;
        last SEARCH;
      }
    }
    confess "Unable to load file for LayoutSet ".$self->name unless $found;
  };

  implements '_load_file' => as {
    my ($self, $file) = @_;
    my $data = $file->slurp;
    my $fragments = $self->fragments;
    # cheesy match for "=for layout fragmentname ... =something"
    # final split group also handles last in file, (?==) is lookahead
    # assertion for '=' so "=for layout fragment1 ... =for layout fragment2"
    # doesn't have the match pos go past the latter = and lose fragment2
    while ($data =~ m/=for layout (.*?)\n(.+?)(?:\n(?==)|$)/sg) {
      my ($fname, $text) = ($1, $2);
      $fragments->{$fname} = $text;
    }
    $self->source_file($file);
  };

  implements 'widget_type' => as {
    my ($self) = @_;
    return join('', map { ucfirst($_) } split('_', $self->name));
  };
      
};

1;

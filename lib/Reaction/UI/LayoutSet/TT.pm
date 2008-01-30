package Reaction::UI::LayoutSet::TT;

use Reaction::Class;
use aliased 'Reaction::UI::LayoutSet';
use aliased 'Template::View';

class TT is LayoutSet, which {

  has 'tt_view' => (is => 'rw', isa => View, lazy_fail => 1);

  implements file_extension => as { 'tt' };

  implements 'BUILD' => as {
    my ($self, $args) = @_;

    # Do this at build time rather than on demand so any exception if it
    # goes wrong gets thrown sometime sensible

    $self->tt_view($self->_build_tt_view($args));
  };

  implements '_build_tt_view' => as {
    my ($self, $args) = @_;
    my $tt_object = $args->{tt_object}
      || confess "tt_object not provided to new()";
    my $tt_args = { data => {} };
    my $name = $self->name;
    $name =~ s/\//__/g; #slashes are not happy here...
    my $layouts = $self->layouts;

    my $tt_source = join("\n", "[%- VIEW ${name};",
      (map {("BLOCK $_; -%]" . $layouts->{$_} ."[%- END;") } keys %$layouts),
        "END; # End view\ndata.view = ${name}; -%]" );

    $tt_object->process(\$tt_source, $tt_args)
      || confess "Template processing error: ".$tt_object->error
                ." processing:\n${tt_source}";
    confess "View template processed but no view object found"
           ." after processing:\n${tt_source}"
      unless $tt_args->{data}{view};
    return $tt_args->{data}{view};
  };

};

1;

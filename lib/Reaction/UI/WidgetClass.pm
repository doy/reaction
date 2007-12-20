package Reaction::UI::WidgetClass;

use Reaction::ClassExporter;
use Reaction::Class;
use Reaction::UI::Widget;
use Data::Dumper;
use Devel::Declare;

no warnings 'once';

class WidgetClass, which {

  overrides exports_for_package => sub {
    my ($self, $package) = @_;
    return (super(),
      func => sub {
                my ($k, $m) = @_;
                my $sig = "should be: func(data_key => 'method_name')";
                confess "Data key not present, ${sig}" unless defined($k);
                confess "Data key must be string, ${sig}" unless !ref($k);
                confess "Method name not present, ${sig}" unless defined($m);
                confess "Method name must be string, ${sig}" unless !ref($m);
                [ $k, $m ];
              }, # XXX zis is not ze grand design. OBSERVABLE.
      string => sub (&) { -string => [ @_ ] }, # meh (maybe &;@ later?)
      wrap => sub { $self->do_wrap_sub($package, @_); }, # should have class.
      fragment => sub (@) { }, # placeholder rewritten by do_import
      over => sub { -over => @_ },
    );
  };

  after do_import => sub {
    my ($self, $pkg, $args) = @_;

    Devel::Declare->install_declarator(
      $pkg, 'fragment', DECLARE_NAME,
      sub { },
      sub {
        our $FRAGMENT_CLOSURE;
        splice(@_, 1, 1); # remove undef proto arg
        $FRAGMENT_CLOSURE->(@_);
      }
    );
  };

  overrides default_base => sub { ('Reaction::UI::Widget') };

  overrides do_class_sub => sub {
    my ($self, $package, $class) = @_;
    # intercepts 'foo renders ...'
    our $FRAGMENT_CLOSURE;
    local $FRAGMENT_CLOSURE = sub {
      $self->do_renders_meth($package, $class, @_);
    };
    # $_ returns '-topic:_', $_{foo} returns '-topic:foo'
    local $_ = '-topic:_';
    my %topichash;
    tie %topichash, 'Reaction::UI::WidgetClass::TopicHash';
    local *_ = \%topichash;
    super;
  };

  implements do_wrap_sub => as { confess "Unimplemented" };

  implements do_renders_meth => as {
    my ($self, $package, $class, $fname, $content, $args, $extra) = @_;

    my $sig = 'should be: renders [ <content spec> ], \%args?';

    confess "Too many args to renders, ${sig}" if defined($extra);
    confess "First arg not an arrayref, ${sig}" unless ref($content) eq 'ARRAY';
    confess "Args must be hashref, ${sig}"
      if (defined($args) && (ref($args) ne 'HASH'));

    $sig .= '
where content spec is [ fragment_name => over (func(...)|$_|$_{keyname}), \%args? ]
  or [ qw(list of fragment names), \%args ]'; # explain the mistake, yea

    my $inner_args = ((ref($content->[-1]) eq 'HASH') ? pop(@$content) : {});
    # [ blah over (func(...)|$_|$_{keyname}), { ... } ] or [ qw(foo bar), { ... } ]

    # predeclare since content_gen gets populated somewhere in an if
    # and inner_args_gen wants to be closed over by content_gen

    my ($content_gen, $inner_args_gen);

    my %args_extra; # again populated (possibly) within the if

    confess "Content spec invalid, ${sig}"
      unless defined($content->[0]) && !ref($content->[0]);

    # new-style over gives 'frag, -over, $func'. massage.

    if (defined($content->[1]) && !ref($content->[1])
        && ($content->[1] eq '-over')) {
      @$content[0,1] = @$content[1,0];
    }

    if (my ($key) = ($content->[0] =~ /^-(.*)?/)) {

      # if first content value is -foo, pull it off the front and then
      # figure out is it's a type we know how to handle

      shift(@$content);
      if ($key eq 'over') { # fragment_name over func
        my ($fragment, $func) = @$content;
        confess "Fragment name invalid, ${sig}" if ref($fragment);
        my $content_meth = "render_${fragment}";
        # grab result of func
        # - if arrayref, render fragment per entry
        # - if obj and can('next') call that until undef
        # - else scream loudly
        unless ((ref($func) eq 'ARRAY') || ($func =~ /^-topic:(.*)$/)) {
          confess "over value wrong, should be ${sig}";
        }
        $content_gen = sub {
          my ($widget, $args) = @_;
          my $topic;
          if (ref($func) eq 'ARRAY') {
            my ($func_key, $func_meth)  = @$func;
            $topic = eval { $args->{$func_key}->$func_meth };
            confess "Error calling ${func_meth} on ${func_key} argument "
              .($args->{$func_key}||'').": $@"
                if $@;
          } elsif ($func =~ /^-topic:(.*)$/) {
            $topic = $args->{$1};
          } else {
            confess "Shouldn't get here";
          }
          my $iter_sub;
          if (ref $topic eq 'ARRAY') {
            my @copy = @$topic; # non-destructive on original data
            $iter_sub = sub { shift(@copy); };
          } elsif (Scalar::Util::blessed($topic) && $topic->can('next')) {
            $iter_sub = sub { $topic->next };
          } else {
            #confess "func(${func_key} => ${func_meth}) for topic within fragment ${fname} did not return arrayref or iterator object";
            # Coercing to a single-arg list instead for the mo. Mistake?
            my @copy = ($topic);
            $iter_sub = sub { shift(@copy); };
          }
          my $inner_args = $inner_args_gen->($args);
          return sub {
            my $next = $iter_sub->();
            return undef unless $next;
            return sub {
              my ($rctx) = @_;
              local $inner_args->{'_'} = $next; # ala local $_, why copy?
              $widget->$content_meth($rctx, $inner_args);
            };
          };
        };
      } elsif ($key eq 'string') {

        # string { ... }

        my $sub = $content->[0]->[0]; # string {} returns (-string => [ $cr ])
        $content_gen = sub {
          my ($widget, $args) = @_;
          my $done = 0;
          my $inner_args = $inner_args_gen->($args);
          return sub {
            return if $done++; # a string content only happens once
            return sub { # setup $_{foo} etc. and alias $_ to $_{_}
              my ($rctx) = @_;
              local *_ = \%{$inner_args};
              local $_ = $inner_args->{'_'};
              $sub->($rctx);
            };
          };
        };

      # must also handle just $_ later for wrap
      } else {
        # unrecognised -foo
        confess "Unrecognised content spec type ${key}, ${sig}";
      }
    } else {

      # handling the renders [ qw(list of frag names), \%args ] case

#warn @$content;
      confess "Invalid content spec, ${sig}"
        if grep { ref($_) } @$content;
      $content_gen = sub {
        my ($widget, $args) = @_;
        my @fragment_methods = map { "render_${_}" } @$content;
        my $inner_args = $inner_args_gen->($args);
        return sub {
          my $next = shift(@fragment_methods);
          return undef unless $next;
          return sub {
            my ($rctx) = @_;
            $widget->$next($rctx, $inner_args);
          };
        };
      };

      foreach my $key (@$content) {
        my $frag_meth = "render_${key}";
        $args_extra{$key} = sub {
          my ($widget, $args) = @_;
          my $inner_args = $inner_args_gen->($args);
          return sub {
            my ($rctx) = @_;
            $widget->$frag_meth($rctx, $inner_args);
          };
        };
      }
    }

    # populate both args generators here primarily for clarity

    my $args_gen = $self->mk_args_generator($args);
    $inner_args_gen = $self->mk_args_generator($inner_args);

    my $methname = "render_${fname}";

    $args_extra{'_'} = $content_gen;

    my @extra_keys = keys %args_extra;
    my @extra_gen = values %args_extra;

    my $meth = sub {
      my ($self, $rctx, $args) = @_;
      confess "No rendering context passed" unless $rctx;
      my $r_args = $args_gen->($args);
#warn Dumper($r_args).' ';
      @{$r_args}{@extra_keys} = map { $_->($self, $args); } @extra_gen;
      $r_args->{'_'} = $content_gen->($self, $args);
#warn Dumper($r_args).' ';
      $rctx->render($self->layout_set, $fname, $r_args);
    };

    $class->meta->add_method($methname => $meth);
  };

  implements do_over_meth => as {
    my ($self, $package, $class, @args) = @_;
    #warn Dumper(\@args);
    return (-over => @args);
  };

  implements mk_args_generator => as {
    my ($self, $argspec) = @_;
#warn Dumper($argspec);
    # only handling [ $k, $v ] (func()) and -topic:$x ($_{$x}) for the moment

    my $sig = 'should be: key => $_ or key => $_{name} or key => func("name", "method")';

    my (@func_to, @func_spec, @copy_from, @copy_to, @sub_spec, @sub_to);
    foreach my $key (keys %$argspec) {
      my $val = $argspec->{$key};
      if (ref($val) eq 'ARRAY') {
        push(@func_spec, $val);
        push(@func_to, $key);
      } elsif (!ref($val) && ($val =~ /^-topic:(.*)$/)) {
        my $topic_key = $1;
        push(@copy_from, $topic_key);
        push(@copy_to, $key);
      }  elsif (ref($val) eq 'CODE') {
      #LOOK AT ME
        my $sub = sub{
          my $inner_args = shift;
          local *_ = \%{$inner_args};
          local $_ = $inner_args->{'_'};
          return $val->();
        };
        push(@sub_spec, $sub);
        push(@sub_to, $key);
      } else {
        confess "Invalid args member for ${key}, ${sig}";
      }
    }
#warn Dumper(\@func_to, \@func_spec, \@copy_from, \@copy_to);
    return sub {
      my ($outer_args) = @_;
      my $args = { %$outer_args };
#warn Dumper(\@func_to, \@func_spec, \@copy_from, \@copy_to).' ';
      @{$args}{@copy_to} = @{$outer_args}{@copy_from};
      @{$args}{@func_to} = (map {
        my ($key, $meth) = @{$_};
        $outer_args->{$key}->$meth; # [ 'a, 'b' ] ~~ ->{'a'}->b
      } @func_spec);
      #LOOK AT ME
      @{$args}{@sub_to} = (map { $_->($outer_args) } @sub_spec);
#warn Dumper($args).' ';
      return $args;
    };
  };

};

1;

package Reaction::UI::WidgetClass::TopicHash;

use Tie::Hash;
use base qw(Tie::StdHash);

sub FETCH {
  my ($self, $key) = @_;
  return "-topic:${key}";
}

1;

__END__;

=head1 NAME

Reaction::UI::WidgetClass

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::WidgetClass;

use Reaction::ClassExporter;
use Reaction::Class;
use Reaction::UI::Widget;
use Data::Dumper;
use Devel::Declare;
use aliased 'Reaction::UI::WidgetClass::_OVER';

no warnings 'once';

class WidgetClass, which {

  # for local() for fragment wrap
  our ($next_call, $fragment_args, $current_widget, $do_render, $new_args);

  after 'do_import' => sub {
    my ($self, $package) = @_;
    Devel::Declare->install_declarator(
      $package, 'fragment', DECLARE_NAME,
      sub { },
      sub {
        WidgetClass->handle_fragment(@_);
      }
    );
  };

  after 'setup_and_cleanup' => sub {
    my ($self, $package) = @_;
    {
      no strict 'refs';
      delete ${"${package}::"}{'fragment'};
    }
    #Devel::Declare->teardown_for($package);
  };

  overrides exports_for_package => sub {
    my ($self, $package) = @_;
    return (super(),
      over => sub {
        my ($collection) = @_;
        confess "too many args, should be: over \$collection" if @_ > 1;
        _OVER->new(collection => $collection);
      },
      render => sub {
        my ($name, $over) = @_;

        my $sig = "should be: render 'name' or render 'name' => over \$coll";
        if (!defined $name) { confess "name undefined: $sig"; }
        if (ref $name) { confess "name not string: $sig"; }
        if (defined $over && !(blessed($over) && $over->isa(_OVER))) {
          confess "invalid args after name, $sig";
        }
        $do_render->($package, $current_widget, $name, $over);
      },
      arg => sub {
        my ($name, $value) = @_;

        my $sig = "should be: arg 'name' => \$value";
        if (@_ < 2) { confess "Not enough arguments, $sig"; }
        if (!defined $name) { confess "name undefined, $sig"; }
        if (ref $name) { confess "name is not a string, $sig"; }

        $new_args->{$name} = $value;
      },
      call_next => sub {
        confess "args passed, should be just call_next; or call_next();"
          if @_;
        $next_call->(@$fragment_args);
      },
      event_id => sub {
        my ($name) = @_;
        $_{viewport}->event_id_for($name);
      },
      event_uri => sub {
        my ($events) = @_;
        my $vp = $_{viewport};
        my %args = map{ $vp->event_id_for($_) => $events->{$_} } keys %$events;
        $vp->ctx->req->uri_with(\%args);
      },
    );
  };

  overrides default_base => sub { ('Reaction::UI::Widget') };

  implements handle_fragment => as {
    my ($self, $name, $proto, $code) = @_;
warn ($self, $name, $code);
    return ("_fragment_${name}" => $self->wrap_as_fragment($code));
  };

  implements wrap_as_fragment => as {
    my ($self, $code) = @_;
    return sub {
      local $next_call;
      if (ref $_[0] eq 'CODE') { # inside 'around' modifier
        $next_call = shift;
      }
      local $fragment_args = \@_;

      # $self->$method($do_render, \%_, $new_args)
      local $current_widget = $_[0];
      local $do_render = $_[1];
      local *_ = \%{$_[2]};
      local $new_args = $_[3];
      $code->(@_);
    };
  };

};

1;

=head1 NAME

Reaction::UI::WidgetClass

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

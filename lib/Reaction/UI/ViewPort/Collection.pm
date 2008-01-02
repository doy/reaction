package Reaction::UI::ViewPort::Collection;

use Reaction::Class;
use Scalar::Util qw/blessed/;
use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::Object';

class Collection is 'Reaction::UI::ViewPort', which {

  has members => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);

  has collection         => (is => 'ro', isa => IM_Collection, required   => 1);
  has current_collection => (is => 'rw', isa => IM_Collection, lazy_build => 1);

  has member_args  => ( is => 'rw', isa => 'HashRef', lazy_build => 1);
  has member_class => ( is => 'ro', isa => 'Str',     lazy_build => 1);

  implements BUILD => as {
    my ($self, $args) = @_;
    my $member_args = delete $args->{Member};
    $self->member_args( $member_args ) if ref $member_args;
  };

  implements _build_member_args => as{ {} };

  implements _build_member_class => as{ Object };

  after clear_current_collection => sub{
    shift->clear_members; #clear the members the current collection changes, duh
  };

  implements _build_current_collection => as {
    shift->collection;
  };

  #I'm not really sure why this is here all of a sudden.
  implements model => as { shift->current_collection };

  implements _build_members => as {
    my ($self) = @_;
    my (@members, $i);
    my $args = $self->member_args;
    my $builders = {};
    my $ctx = $self->ctx;
    my $loc = join('-', $self->location, 'member');
    my $class = $self->member_class;

    #replace $i with a real unique identifier so that we don't run a risk of
    # events being passed down to the wrong viewport. for now i disabled event
    # passing until i fix this (groditi)
    for my $obj ( $self->current_collection->members ) {
      my $type = blessed $obj;
      my $builder_cache = $builders->{$type} ||= {};
      my $member = $class->new(
                            ctx           => $ctx,
                            model         => $obj,
                            location      => join('-', $loc, $i++),
                            builder_cache => $builder_cache,
                            %$args
                           );
      push(@members, $member);
    }
    return \@members;
  };

};



1;

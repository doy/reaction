package Reaction::UI::ViewPort::Collection;

use Reaction::Class;
use Scalar::Util qw/blessed/;
use aliased 'Reaction::InterfaceModel::Collection' => 'IM_Collection';
use aliased 'Reaction::UI::ViewPort::Object';

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::ViewPort';

has members => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);

has collection         => (is => 'ro', isa => IM_Collection, required   => 1);
has current_collection => (is => 'rw', isa => IM_Collection, lazy_build => 1);

has member_args  => ( is => 'rw', isa => 'HashRef', lazy_build => 1);
has member_class => ( is => 'ro', isa => 'Str',     lazy_build => 1);

sub BUILD {
  my ($self, $args) = @_;
  if( my $member_args = delete $args->{Member} ){
    $self->member_args( $member_args );
  }
}

sub _build_member_args { {} }

sub _build_member_class { Object };

after clear_current_collection => sub{
  shift->clear_members; #clear the members the current collection changes, duh
};

sub _build_current_collection {
  return $_[0]->collection;
}

#I'm not really sure why this is here all of a sudden.
sub model { shift->current_collection }

sub _build_members {
  my ($self) = @_;
  my (@members, $i);
  my $args = $self->member_args;
  my $builders = {};
  my $field_orders = {};
  my $ctx = $self->ctx;
  my $loc = join('-', $self->location, 'member');
  my $class = $self->member_class;

  #replace $i with a real unique identifier so that we don't run a risk of
  # events being passed down to the wrong viewport. for now i disabled event
  # passing until i fix this (groditi)
  for my $obj ( $self->current_collection->members ) {
    my $type = blessed $obj;
    my $builder_cache = $builders->{$type} ||= {};
    my @order;
    if( exists $args->{computed_field_order} ){
      @order = (computed_field_order => $args->{computed_field_order});
    } elsif( exists $field_orders->{$type} ) {
      @order = (computed_field_order => $field_orders->{$type});
    }

    my $member = $class->new(
      ctx => $ctx,
      model => $obj,
      location => join('-', $loc, $i++),
      builder_cache => $builder_cache,
      @order, %$args,
    );

    #cache to prevent the sort function from having to be run potentially
    #hundreds of times
    $field_orders->{$type} ||= $member->computed_field_order unless @order;
    push(@members, $member);
  }
  return \@members;
};

__PACKAGE__->meta->make_immutable;


1;

__END__;

=head1 NAME

Reaction::UI::ViewPort::Collection

=head1 DESCRIPTION

Creates, from an InterfaceModel::Collection, a list of viewports representing each
member of the collection.

=head1 ATTRIBUTES

=head2 collection

=head2 current_collection

=head2 member_args

=head2 member_class

=head1 INTERNAL METHODS

These methods, although stable, are subject to change without notice. These are meant
to be used only by developers. End users should refrain from using these methods to
avoid potential breakages.

=head2 BUILD

=head2 get_builder_for

=head2 model

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

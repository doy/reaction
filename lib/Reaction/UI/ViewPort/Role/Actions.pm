package Reaction::UI::ViewPort::Role::Actions;

use Reaction::Role;
use Reaction::UI::ViewPort::URI;

use namespace::clean -except => [ qw(meta) ];

has actions => (
  is => 'ro',
  isa => 'ArrayRef',
  lazy_build => 1
);

has action_order => (
  is => 'ro',
  isa => 'ArrayRef'
);

has action_prototypes => (
  is => 'ro',
  isa => 'HashRef',
  required => 1,
  default => sub{ {} }
);

has computed_action_order => (
  is => 'ro',
  isa => 'ArrayRef',
  lazy_build => 1
);

sub _build_computed_action_order {
  my $self = shift;
  my $ordered = $self->sort_by_spec(
    ($self->has_action_order ? $self->action_order : []),
    [ keys %{ $self->action_prototypes } ]
  );
  return $ordered ;
}

sub _build_actions {
  my ($self) = @_;
  my (@act, $i);
  my $ctx = $self->ctx;
  my $loc = $self->location;
  my $target = $self->model;

  foreach my $proto_name ( @{ $self->computed_action_order } ) {
    my $proto = $self->action_prototypes->{$proto_name};
    my $uri = $proto->{uri} or confess('uri is required in prototype action');
    my $label = exists $proto->{label} ? $proto->{label} : $proto_name;

    my $action = Reaction::UI::ViewPort::URI->new(
      location => join ('-', $loc, 'action', $i++),
      uri => ( ref($uri) eq 'CODE' ? $uri->($target, $ctx) : $uri ),
      display => ( ref($label) eq 'CODE' ? $label->($target, $ctx) : $label ),
    );
    push(@act, $action);
  }
  return \@act;
}

1;

__END__;

=head1 NAME

Reaction::UI::ViewPort::Role::Actions

=head1 DESCRIPTION

A role to ease attaching actions to L<Reaction::InterfaceModel::Object>s

=head1 ATTRIBUTES

=head2 actions

Automatically built ArrayRef of URI objects pointing to actions

=head2 action_prototypes

A HashRef of prototypes for building the Action links. The prototypes should be
composed like these:

    my %action_prototypes = (
      example_action => { label => 'Example Action', uri => $uri_obj },
    );

    #or you can get fancy and do something like what is below:
    sub make_label{
      my($im, $ctx) =  @_; #InterfaceModel::Object/Collection, Catalyst Context
      return 'label_text';
    }
    sub make_uri{
      my($im, $ctx) =  @_; #InterfaceModel::Object/Collection, Catalyst Context
      return return $ctx->uri_for('some_action');
    }
    my %action_prototypes = (
      example_action => { label => \&make_label, uri => \&make_uri },
    );

=head2 action_order

User-provided ArrayRef with how the actions should be ordered eg

     action_order => [qw/view edit delete/]

=head2 computed_action_order

The final computed action order. This may differ from the action_order provided
if you didn't list all of the actions in that.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

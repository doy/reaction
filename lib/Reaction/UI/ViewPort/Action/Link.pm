package Reaction::UI::ViewPort::Action::Link;

use Reaction::Class;

class Link is 'Reaction::UI::ViewPort', which {

  has label  => (is => 'rw',  required => 1);
  has uri    => ( is => 'rw', lazy_build => 1);

  has target => (isa => 'Object',  is => 'rw', required   => 1);
  has action => (isa => 'CodeRef', is => 'rw', required   => 1);

  implements BUILD => as {
    my $self = shift;
    $self->label( $self->label->($self->target) ) if ref $self->label eq 'CODE';
  };

  implements _build_uri => as{
    my $self = shift;
    my $c = $self->ctx;
    my ($c_name, $a_name, @rest) = @{ $self->action->($self->target, $c) };
    $c->uri_for($c->controller($c_name)->action_for($a_name),@rest);
  };

};

1;

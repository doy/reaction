package Reaction::UI::ViewPort::Field::File;

use Reaction::Class;
use Reaction::Types::File;

class File is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => Reaction::Types::File::File());

  has uri    => ( is => 'rw', lazy_build => 1);

  has action => (isa => 'CodeRef', is => 'rw', required   => 1);

  implements _build_uri => as{
    my $self = shift;
    my $c = $self->ctx;
    my ($c_name, $a_name, @rest) = @{ $self->action->($self->model, $c) };
    $c->uri_for($c->controller($c_name)->action_for($a_name),@rest);
  };

  implements _value_string_from_value => as {
      shift->value->stringify;
  };
    
};

1;

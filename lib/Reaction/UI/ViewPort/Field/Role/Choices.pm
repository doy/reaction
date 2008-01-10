package Reaction::UI::ViewPort::Field::Role::Choices;

use Reaction::Role;
use URI;
use Scalar::Util 'blessed';

role Choices, which {

  has valid_values  => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has value_choices => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);
  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  implements str_to_ident => as {
    my ($self, $str) = @_;
    my $u = URI->new('','http');
    $u->query($str);
    return { $u->query_form };
  };

  implements obj_to_str => as {
    my ($self, $obj) = @_;
    return $obj unless ref($obj);
    confess "${obj} not an object" unless blessed($obj);
    my $ident = $obj->ident_condition; #XXX DBIC ism that needs to go away
    my $u = URI->new('', 'http');
    $u->query_form(%$ident);
    return $u->query;
  };

  implements obj_to_name => as {
    my ($self, $obj) = @_;
    return $obj unless ref($obj);
    confess "${obj} not an object" unless blessed($obj);
    my $meth = $self->value_map_method;
    return $obj->$meth;
  };

  implements _build_valid_values => as {
    my $self = shift;
    return [ $self->attribute->all_valid_values($self->action) ];
  };

  implements _build_value_choices => sub{
    my $self  = shift;
    my @pairs = map{{value => $self->obj_to_str($_), name => $self->obj_to_name($_)}}
      @{ $self->valid_values };
    return [ sort { $a->{name} cmp $b->{name} } @pairs ];
  };

};

1;

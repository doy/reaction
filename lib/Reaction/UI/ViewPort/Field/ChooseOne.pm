package Reaction::UI::ViewPort::Field::ChooseOne;

use Reaction::Class;
use URI;
use Scalar::Util 'blessed';

class ChooseOne is 'Reaction::UI::ViewPort::Field', which {

  has '+layout' => (default => 'select');

  has valid_value_names => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);

  has valid_values => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);

  has name_to_value_map => (isa => 'HashRef', is => 'ro', lazy_build => 1);

  has value_to_name_map => (isa => 'HashRef', is => 'ro', lazy_build => 1);

  has value_map_method => (
    isa => 'Str', is => 'ro', required => 1, default => sub { 'display_name' },
  );

  around value => sub {
    my $orig = shift;
    my $self = shift;
    if (@_) {
      my $value = shift;
      if (defined $value) {
        if (!ref $value) {
          $value = $self->str_to_ident($value);
        }
        my $checked = $self->attribute->check_valid_value($self->action, $value);
        confess "${value} is not a valid value" unless defined($checked);
        $value = $checked;
      }
      $orig->($self, $value);
    } else {
      $orig->($self);
    }
  };

  implements build_valid_values => as {
    my $self = shift;
    return [ $self->attribute->all_valid_values($self->action) ];
  };

  implements build_valid_value_names => as {
    my $self = shift;
    my $all = $self->valid_values;
    my $meth = $self->value_map_method;
    my @names = map { $_->$meth } @$all;
    return [ sort @names ];
  };

  implements build_name_to_value_map => as {
    my $self = shift;
    my $all = $self->valid_values;
    my $meth = $self->value_map_method;
    my %map;
    $map{$_->$meth} = $self->obj_to_str($_) for @$all;
    return \%map;
  };

  implements build_value_to_name_map => as {
    my $self = shift;
    my $all = $self->valid_values;
    my $meth = $self->value_map_method;
    my %map;
    $map{$self->obj_to_str($_)} = $_->$meth for @$all;
    return \%map;
  };

  implements is_current_value => as {
    my ($self, $check_value) = @_;
    my $our_value = $self->value;
    return unless ref($our_value);
    $check_value = $self->obj_to_str($check_value) if ref($check_value);
    return $self->obj_to_str($our_value) eq $check_value;
  };

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
    my $ident = $obj->ident_condition;
    my $u = URI->new('', 'http');
    $u->query_form(%$ident);
    return $u->query;
  };

};

1;

=head1 NAME

Reaction::UI::ViewPort::Field::ChooseOne

=head1 DESCRIPTION

=head1 METHODS

=head2 is_current_value

=head2 value

=head2 valid_values

=head2 valid_value_names

=head2 value_to_name_map

=head2 name_to_value_map

=head2 str_to_ident

=head2 obj_to_str

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

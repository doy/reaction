package Reaction::UI::ViewPort::Field::Mutable::ChooseOne;

use Reaction::Class;
use Scalar::Util ();

class ChooseOne is 'Reaction::UI::ViewPort::Field', which {

  does 'Reaction::UI::ViewPort::Field::Role::Mutable';
  does 'Reaction::UI::ViewPort::Field::Role::Choices';

  around value => sub {
    my $orig = shift;
    my $self = shift;
    return $orig->($self) unless @_;
    my $value = shift;
    if (defined $value) {
      $value = $self->str_to_ident($value) if (!ref $value);
      my $attribute = $self->attribute;
      my $checked = $attribute->check_valid_value($self->model, $value);
      unless (defined $checked) {
        require Data::Dumper; 
        my $serialised = Data::Dumper->new([ $value ])->Indent(0)->Dump;
        $serialised =~ s/^\$VAR1 = //; $serialised =~ s/;$//;
        confess "${serialised} is not a valid value for ${\$attribute->name} on "
                ."${\$attribute->associated_class->name}";
      }
      $value = $checked;
    }
    $orig->($self, $value);
  };

  implements _build_value_string => as {
    my $self = shift;
    my $value = $self->value;
    return $self->obj_to_name($value->{value}) if Scalar::Util::blessed($value);
    $value;
  };

  implements is_current_value => as {
    my ($self, $check_value) = @_;
    my $our_value = $self->value;
    return unless ref($our_value);
    $check_value = $self->obj_to_str($check_value) if ref($check_value);
    return $self->obj_to_str($our_value) eq $check_value;
  };


};

1;

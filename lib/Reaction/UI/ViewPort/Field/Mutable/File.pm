package Reaction::UI::ViewPort::Field::Mutable::File;

use Reaction::Types::File qw/Upload/;
use Reaction::Class;

class File is 'Reaction::UI::ViewPort::Field', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable::Simple';

  has '+value' => (isa => Upload);

  override apply_our_events => sub {
    my ($self, $ctx, $events) = @_;
    my $value_key = $self->event_id_for('value_string');
    if (my $upload = $ctx->req->upload($value_key)) {
      local $events->{$value_key} = $upload;
      return super();
    } else {
      return super();
    }
  };

  implements adopt_value_string => sub {
      my($self) = @_;
      $self->value($self->value_string) if $self->value_string;
  };

  overrides _value_string_from_value => sub { '' };

};

1;

package Reaction::UI::ViewPort::Field::Mutable::File;

use Reaction::Class;
use Reaction::Types::File;

class File is 'Reaction::UI::ViewPort::Field', which {
  does 'Reaction::UI::ViewPort::Field::Role::Mutable';

  has '+value' => (isa => 'Upload');

  override apply_our_events => sub {
    my ($self, $ctx, $events) = @_;
    my $value_key = join(':', $self->location, 'value');
    if (my $upload = $ctx->req->upload($value_key)) {
      local $events->{$value_key} = $upload;
      return super();
    } else {
      return super();
    }
  };

};

1;

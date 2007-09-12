package Reaction::UI::ViewPort::Field::HiddenArray;

use Reaction::Class;

class HiddenArray is 'Reaction::UI::ViewPort::Field', which {

  has '+value' => (isa => 'ArrayRef');
  
  around value => sub {
    my $orig = shift;
    my $self = shift;
    if (@_) {
      $orig->($self, (ref $_[0] eq 'ARRAY' ? $_[0] : [ $_[0] ]));
      $self->sync_to_action;
    } else {
      $orig->($self);
    }
  };

};

1;  

=head1 NAME

Reaction::UI::ViewPort::Field::HiddenArray

=head1 DESCRIPTION

=head1 SEE ALSO

=head2 L<Reaction::UI::ViewPort::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

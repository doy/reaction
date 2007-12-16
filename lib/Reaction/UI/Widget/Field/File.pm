package Reaction::UI::Widget::Field::File;

use Reaction::UI::WidgetClass;

class File is 'Reaction::UI::Widget::Field', which {

  after fragment widget {
    arg field_type => 'file';
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::File

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::Widget::Collection;

use Reaction::UI::WidgetClass;

class Collection, which {

  implements fragment members {
    render member => over $_{viewport}->members;
  };

  implements fragment member {
    render 'viewport';
  };

};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Collection

=head1 DESCRIPTION

=head1 FRAGMENTS

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

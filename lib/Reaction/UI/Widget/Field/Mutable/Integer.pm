package Reaction::UI::Widget::Field::Mutable::Integer;

use Reaction::UI::WidgetClass;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::UI::Widget::Field::Mutable';



__PACKAGE__->meta->make_immutable;


1;

__END__;

=head1 NAME

Reaction::UI::Widget::Field::Mutable::Integer

=head1 DESCRIPTION

See L<Reaction::UI::Widget::Field>
See L<Reaction::UI::Widget::Field::Mutable>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

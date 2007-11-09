package Reaction::UI::Widget::Value;

use Reaction::UI::WidgetClass;

class Value, which {
  fragment widget [ string {""} ],
    { value => sub{
        my $vp = $_{viewport};
        $vp->can('value_string') ? $vp->value_string : $vp->value;
      }
    };
};

1;

__END__;

=head1 NAME

Reaction::UI::Widget::Value

=head1 DESCRIPTION

=head1 FRAGMENTS

=head2 widget

Additional variables available in topic hash: "viewport".

Renders "label" and "field"

=head2 field

 C<content> will contain the value, if any,  of the field.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

=head1 NAME

Reaction::Manual::Troubleshooting - Got a Reaction problem? Shoot it.

=head2 Invalid CODE attributes: ...

You need to inherit from L<Reaction::UI::Controller> for the Catalyst action
attributes to be available.

=head3 But I did inherit from Reaction::UI::Controller using Moose

You have to run the extends at compile time for perl attributes to work:

    BEGIN {
        extends 'Reaction::UI::Controller';
    }

Welcome to hating attributes.

=cut

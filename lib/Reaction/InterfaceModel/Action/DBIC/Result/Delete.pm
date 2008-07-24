package Reaction::InterfaceModel::Action::DBIC::Result::Delete;

use aliased 'Reaction::InterfaceModel::Action::DBIC::Result';
use aliased 'Reaction::InterfaceModel::Action::Role::SimpleMethodCall';
use Reaction::Types::DBIC 'Row';
use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends Result;

with SimpleMethodCall;
sub _target_model_method { 'delete' };

__PACKAGE__->meta->make_immutable;


1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::Result::Delete

=head1 DESCRIPTION

=head2 target_model

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

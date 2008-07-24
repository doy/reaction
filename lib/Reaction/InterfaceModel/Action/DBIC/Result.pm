package Reaction::InterfaceModel::Action::DBIC::Result;

use Reaction::InterfaceModel::Action;
use Reaction::Types::DBIC 'Row';
use Reaction::Class;

use namespace::clean -except => [ qw(meta) ];
extends 'Reaction::InterfaceModel::Action';



has '+target_model' => (isa => Row);

__PACKAGE__->meta->make_immutable;


1;

package Reaction::InterfaceModel::Action::Search::UpdateSpec;

use Reaction::Class;
#use aliased 'BrokerInterface::SearchSpec';
use Method::Signatures::Simple;
use Reaction::InterfaceModel::Reflector::SearchSpec;
use Carp qw( confess );

use namespace::clean -except => 'meta';

extends 'Reaction::InterfaceModel::Action';

my %ReflectionCache;

method build_reflected_search_spec () {
    confess sprintf "Class %s did not override the build_reflected_search_spec method", ref($self) || $self;
}

method _reflection_info () {
    $ReflectionCache{ ref($self) || $self }
        ||= reflect_attributes_from_target $self->build_reflected_search_spec;
}

with 'Reaction::InterfaceModel::Search::UpdateSpec';

1;


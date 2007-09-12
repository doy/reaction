package Reaction::InterfaceModel::DBIC::Collection;

use Reaction::Class;
use aliased 'DBIx::Class::ResultSet';

#this will be reworked to isa Reaction::InterfaceModel::Collection as soon as the
#API for that is finalized.

class Collection is ResultSet, is 'Reaction::Object', which {

  #this really needs to be smarter, fine for CRUD, shit for anything else
  # massive fucking reworking needed here, really
  implements '_default_action_args_for' => as { {} };

  implements '_override_action_args_for' => as {
    my ($self) = @_;
    # reset result_class
    my $rs = $self->search_rs
      ({}, { result_class => $self->result_source->result_class });
    return { target_model => $rs };
  };

  #feel like it should be an attribute
  implements '_action_class_map' => as { {} };

  #feel like it should be a lazy_build attribute
  implements '_default_action_class_prefix' => as {
    shift->result_class;
  };

  implements '_default_action_class_for' => as {
    my ($self, $action) = @_;
    return $self->_default_action_class_prefix.'::Action::'.$action;
  };

  implements '_action_class_for' => as {
    my ($self, $action) = @_;
    if (defined (my $class = $self->_action_class_map->{$action})) {
      return $class;
    }
    return $self->_default_action_class_for($action);
  };

  implements 'action_for' => as {
    my ($self, $action, %args) = @_;
    my $class = $self->_action_class_for($action);
    %args = (
             %{$self->_default_action_args_for($action)},
             %args,
             %{$self->_override_action_args_for($action)},
            );
    return $class->new(%args);
  };
};

1;

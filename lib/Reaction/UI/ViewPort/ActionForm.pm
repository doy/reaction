package Reaction::UI::ViewPort::ActionForm;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Field::Text';
use aliased 'Reaction::UI::ViewPort::Field::Number';
use aliased 'Reaction::UI::ViewPort::Field::Boolean';
use aliased 'Reaction::UI::ViewPort::Field::File';
use aliased 'Reaction::UI::ViewPort::Field::String';
use aliased 'Reaction::UI::ViewPort::Field::Password';
use aliased 'Reaction::UI::ViewPort::Field::DateTime';
use aliased 'Reaction::UI::ViewPort::Field::ChooseOne';
use aliased 'Reaction::UI::ViewPort::Field::ChooseMany';
use aliased 'Reaction::UI::ViewPort::Field::HiddenArray';
use aliased 'Reaction::UI::ViewPort::Field::TimeRange';

class ActionForm is 'Reaction::UI::ViewPort', which {
  has action => (
                 isa => 'Reaction::InterfaceModel::Action', is => 'ro', required => 1
                );

  has ordered_fields => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);

  has _field_map => (
                     isa => 'HashRef', is => 'rw', init_arg => 'fields', lazy_build => 1,
                    );

  has changed => (
                  isa => 'Int', is => 'rw', reader => 'is_changed', default => sub { 0 }
                 );

  has next_action => (
                      isa => 'ArrayRef', is => 'rw', required => 0, predicate => 'has_next_action'
                     );

  has on_apply_callback => (
                            isa => 'CodeRef', is => 'rw', required => 0,
                            predicate => 'has_on_apply_callback'
                           );

  has ok_label => (
                   isa => 'Str', is => 'rw', required => 1, default => sub { 'ok' }
                  );

  has apply_label => (
                      isa  => 'Str', is => 'rw', required => 1, default => sub { 'apply' }
                     );

  has close_label => (isa => 'Str', is => 'rw', lazy_fail => 1);

  has close_label_close => (
                            isa => 'Str', is => 'rw', required => 1, default => sub { 'close' }
                           );

  has close_label_cancel => (
                             isa => 'Str', is => 'rw', required => 1, default => sub { 'cancel' }
                            );

  sub fields { shift->_field_map }

  implements BUILD => as {
    my ($self, $args) = @_;
    unless ($self->_has_field_map) {
      my @field_map;
      my $action = $self->action;
      foreach my $attr ($action->parameter_attributes) {
        push(@field_map, $self->_build_fields_for($attr => $args));
      }
      $self->_field_map({ @field_map });
    }
    $self->close_label($self->close_label_close);
  };

  implements _build_fields_for => as {
    my ($self, $attr, $args) = @_;
    my $attr_name = $attr->name;
    #TODO: DOCUMENT ME!!!!!!!!!!!!!!!!!
    my $builder = "_build_fields_for_name_${attr_name}";
    my @fields;
    if ($self->can($builder)) {
      @fields = $self->$builder($attr, $args); # re-use coderef from can()
    } elsif ($attr->has_type_constraint) {
      my $constraint = $attr->type_constraint;
      my $base_name = $constraint->name;
      my $tried_isa = 0;
    CONSTRAINT: while (defined($constraint)) {
        my $name = $constraint->name;
        $name = $attr->_isa_metadata if($name eq '__ANON__');
        if (eval { $name->can('meta') } && !$tried_isa++) {
          foreach my $class ($name->meta->class_precedence_list) {
            my $mangled_name = $class;
            $mangled_name =~ s/:+/_/g;
            my $builder = "_build_fields_for_type_${mangled_name}";
            if ($self->can($builder)) {
              @fields = $self->$builder($attr, $args);
              last CONSTRAINT;
            }
          }
        }
        if (defined($name)) {
          unless (defined($base_name)) {
            $base_name = "(anon subtype of ${name})";
          }
          my $mangled_name = $name;
          $mangled_name =~ s/:+/_/g;
          my $builder = "_build_fields_for_type_${mangled_name}";
          if ($self->can($builder)) {
            @fields = $self->$builder($attr, $args);
            last CONSTRAINT;
          }
        }
        $constraint = $constraint->parent;
      }
      if (!defined($constraint)) {
        confess "Can't build field ${attr_name} of type ${base_name} without $builder method or _build_fields_for_type_<type> method for type or any supertype";
      }
    } else {
      confess "Can't build field ${attr} without $builder method or type constraint";
    }
    return @fields;
  };

  implements _build_field_map => as {
    confess "Lazy field map building not supported by default";
  };

  implements _build_ordered_fields => as {
    my $self = shift;
    my $ordered = $self->sort_by_spec($self->column_order, [keys %{$self->_field_map}]);
    return [@{$self->_field_map}{@$ordered}];
  };

  implements can_apply => as {
    my ($self) = @_;
    foreach my $field ( @{ $self->ordered_fields } ) {
      return 0 if $field->needs_sync;
      # if e.g. a datetime field has an invalid value that can't be re-assembled
      # into a datetime object, the action may be in a consistent state but
      # not synchronized from the fields; in this case, we must not apply
    }
    return $self->action->can_apply;
  };

  implements do_apply => as {
    my $self = shift;
    return $self->action->do_apply;
  };

  implements ok => as {
    my $self = shift;
    if ($self->apply(@_)) {
      $self->close(@_);
    }
  };

  implements apply => as {
    my $self = shift;
    if ($self->can_apply && (my $result = $self->do_apply)) {
      $self->changed(0);
      $self->close_label($self->close_label_close);
      $self->on_apply_callback->($self => $result) if $self->has_on_apply_callback;
      return 1;
    } else {
      $self->changed(1);
      $self->close_label($self->close_label_cancel);
      return 0;
    }
  };

  implements close => as {
    my $self = shift;
    my ($controller, $name, @args) = @{$self->next_action};
    $controller->pop_viewport;
    $controller->$name($self->action->ctx, @args);
  };

  sub can_close { 1 }

  override accept_events => sub {
    (($_[0]->has_next_action ? ('ok', 'close') : ()), 'apply', super());
  }; # can't do a close-type operation if there's nowhere to go afterwards

  override child_event_sinks => sub {
    my ($self) = @_;
    return ((grep { ref($_) =~ 'Hidden' } values %{$self->_field_map}),
            (grep { ref($_) !~ 'Hidden' } values %{$self->_field_map}),
            super());
  };

  after apply_child_events => sub {
    # interrupt here because fields will have been updated
    my ($self) = @_;
    $self->sync_action_from_fields;
  };

  implements sync_action_from_fields => as {
    my ($self) = @_;
    my $field_map = $self->_field_map;
    my @fields = values %{$field_map};
    foreach my $field (@fields) {
      $field->sync_to_action; # get the field to populate the $action if possible
    }
    $self->action->sync_all;
    foreach my $field (@fields) {
      $field->sync_from_action; # get errors from $action if applicable
    }
  };

  implements _build_simple_field => as {
    my ($self, $class, $attr, $args) = @_;
    my $attr_name = $attr->name;
    my %extra;
    if (my $config = $args->{Field}{$attr_name}) {
      %extra = %$config;
    }
    my $field = $class->new(
                            action => $self->action,
                            attribute => $attr,
                            name => $attr->name,
                            location => join('-', $self->location, 'field', $attr->name),
                            ctx => $self->ctx,
                            %extra
                           );
    return ($attr_name => $field);
  };

  implements _build_fields_for_type_Num => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(Number, $attr, $args);
  };

  implements _build_fields_for_type_Int => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(Number, $attr, $args);
  };

  implements _build_fields_for_type_Bool => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(Boolean, $attr, $args);
  };

  implements _build_fields_for_type_File => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(File, $attr, $args);
  };

  implements _build_fields_for_type_Str => as {
    my ($self, $attr, $args) = @_;
    if ($attr->has_valid_values) { # There's probably a better way to do this
      return $self->_build_simple_field(ChooseOne, $attr, $args);
    }
    return $self->_build_simple_field(Text, $attr, $args);
  };

  implements _build_fields_for_type_SimpleStr => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(String, $attr, $args);
  };

  implements _build_fields_for_type_Password => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(Password, $attr, $args);
  };

  implements _build_fields_for_type_DateTime => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(DateTime, $attr, $args);
  };

  implements _build_fields_for_type_Enum => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(ChooseOne, $attr, $args);
  };

  #implements build_fields_for_type_Reaction_InterfaceModel_Object => as {
  implements _build_fields_for_type_Row => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(ChooseOne, $attr, $args);
  };

  implements _build_fields_for_type_ArrayRef => as {
    my ($self, $attr, $args) = @_;
    if ($attr->has_valid_values) {
      return $self->_build_simple_field(ChooseMany, $attr, $args)
    } else {
      return $self->_build_simple_field(HiddenArray, $attr, $args)
    }
  };

  implements _build_fields_for_type_Spanset => as {
    my ($self, $attr, $args) = @_;
    return $self->_build_simple_field(TimeRange, $attr, $args);
  };

  no Moose;

  no strict 'refs';
  delete ${__PACKAGE__ . '::'}{inner};

};

  1;

=head1 NAME

Reaction::UI::ViewPort::ActionForm

=head1 SYNOPSIS

  use aliased 'Reaction::UI::ViewPort::ActionForm';

  $self->push_viewport(ActionForm,
    layout => 'register',
    action => $action,
    next_action => [ $self, 'redirect_to', 'accounts', $c->req->captures ],
    ctx => $c,
    column_order => [
      qw / contact_title company_name email address1 address2 address3
           city country post_code telephone mobile fax/ ],
  );

=head1 DESCRIPTION

This subclass of viewport is used for rendering a collection of
L<Reaction::UI::ViewPort::Field> objects for user editing.

=head1 ATTRIBUTES

=head2 action

L<Reaction::InterfaceModel::Action>

=head2 ok_label

Default: 'ok'

=head2 apply_label

Default: 'apply'

=head2 close_label_close

Default: 'close'

=head2 close_label_cancel

This label is only shown when C<changed> is true.

Default: 'cancel'

=head2 fields

=head2 can_apply

=head2 can_close

=head2 changed

Returns true if a field has been edited.

=head2 next_action

=head2 on_apply_callback

CodeRef.

=head1 METHODS

=head2 ok

Calls C<apply>, and then C<close> if successful.

=head2 close

Pop viewport and proceed to C<next_action>.

=head2 apply

Attempt to save changes and update C<changed> attribute if required.

=head1 SEE ALSO

L<Reaction::UI::ViewPort>

L<Reaction::InterfaceModel::Action>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::UI::ViewPort::Action;

use Reaction::Class;

use aliased 'Reaction::UI::ViewPort::Field::Mutable::Text';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Array';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::String';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Number';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Integer';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Boolean';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::Password';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::DateTime';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::ChooseOne';
use aliased 'Reaction::UI::ViewPort::Field::Mutable::ChooseMany';

#use aliased 'Reaction::UI::ViewPort::InterfaceModel::Field::Mutable::File';
#use aliased 'Reaction::UI::ViewPort::InterfaceModel::Field::Mutable::TimeRange';

class Action is 'Reaction::UI::ViewPort::Object', which {
  has model  => (is => 'ro', isa => 'Reaction::InterfaceModel::Action', required => 1);
  #has '+model' => (isa => 'Reaction::InterfaceModel::Action');

  has next_action       => (is => 'rw', isa => 'ArrayRef');
  has on_apply_callback => (is => 'rw', isa => 'CodeRef');

  has ok_label           => (is => 'rw', isa => 'Str', lazy_build => 1);
  has apply_label        => (is => 'rw', isa => 'Str', lazy_build => 1);
  has close_label        => (is => 'rw', isa => 'Str', lazy_fail  => 1);
  has close_label_close  => (is => 'rw', isa => 'Str', lazy_build => 1);
  has close_label_cancel => (is => 'rw', isa => 'Str', lazy_build => 1);

  has changed => (is => 'rw', isa => 'Int', reader => 'is_changed', default => sub{0});

  implements BUILD => as{
    my $self = shift;
    $self->close_label($self->close_label_close);
  };

  implements _build_ok_label           => as{ 'ok'     };
  implements _build_apply_label        => as{ 'apply'  };
  implements _build_close_label_close  => as{ 'close'  };
  implements _build_close_label_cancel => as{ 'cancel' };

  implements can_apply => as {
    my ($self) = @_;
    foreach my $field ( @{ $self->fields } ) {
      return 0 if $field->needs_sync;
      # if e.g. a datetime field has an invalid value that can't be re-assembled
      # into a datetime object, the action may be in a consistent state but
      # not synchronized from the fields; in this case, we must not apply
    }
    return $self->model->can_apply;
  };

  implements do_apply => as {
    shift->model->do_apply;
  };

  implements ok => as {
    my $self = shift;
    $self->close(@_) if $self->apply(@_);
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
    $controller->$name($self->ctx, @args);
  };

  implements can_close => as { 1 };

  override accept_events => sub {
    (($_[0]->has_next_action ? ('ok', 'close') : ()), 'apply', super());
  }; # can't do a close-type operation if there's nowhere to go afterwards

  after apply_child_events => sub {
    # interrupt here because fields will have been updated
    my ($self) = @_;
    $self->sync_action_from_fields;
  };

  implements sync_action_from_fields => as {
    my ($self) = @_;
    foreach my $field (@{$self->fields}) {
      $field->sync_to_action; # get the field to populate the $action if possible
    }
    $self->model->sync_all;
    foreach my $field (@{$self->fields}) {
      $field->sync_from_action; # get errors from $action if applicable
    }
  };


  implements _build_fields_for_type_Num => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Number, %$args);
  };

  implements _build_fields_for_type_Int => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Integer, %$args);
  };

  implements _build_fields_for_type_Bool => as {
    my ($self,  $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Boolean, %$args);
  };

  implements _build_fields_for_type_SimpleStr => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => String, %$args);
  };

  #implements _build_fields_for_type_File => as {
  #  my ($self, $attr, $args) = @_;
  #  $self->_build_simple_field(attribute => $attr, class => File, %$args);
  #};

  implements _build_fields_for_type_Str => as {
    my ($self, $attr, $args) = @_;
    if ($attr->has_valid_values) { # There's probably a better way to do this
      $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
    } else {
      $self->_build_simple_field(attribute => $attr, class => Text, %$args);
    }
  };

  implements _build_fields_for_type_Password => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => Password, %$args);
  };

  implements _build_fields_for_type_DateTime => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => DateTime, %$args);
  };

  implements _build_fields_for_type_Enum => as {
    my ($self, $attr, $args) = @_;
      $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
  };

  #this needs to be fixed. somehow. beats the shit our of me. really.
  #implements build_fields_for_type_Reaction_InterfaceModel_Object => as {
  implements _build_fields_for_type_Row => as {
    my ($self, $attr, $args) = @_;
    $self->_build_simple_field(attribute => $attr, class => ChooseOne, %$args);
  };

  implements _build_fields_for_type_ArrayRef => as {
    my ($self, $attr, $args) = @_;
    if ($attr->has_valid_values) {
      $self->_build_simple_field(attribute => $attr, class => ChooseMany,  %$args);
    } else {
      $self->_build_simple_field
        (
         attribute => $attr,
         class     => Array,
         layout    => 'interface_model/field/mutable/array/hidden',
         %$args);
    }
  };

  #implements _build_fields_for_type_DateTime_Spanset => as {
  #  my ($self, $attr, $args) = @_;
  #    $self->_build_simple_field(attribute => $attr, class => TimeRange,  %$args);
  #};

};

  1;

=head1 NAME

Reaction::UI::ViewPort::InterfaceModel::Action

=head1 SYNOPSIS

  use aliased 'Reaction::UI::ViewPort::Action';

  $self->push_viewport(Action,
    layout => 'register',
    model => $action,
    next_action => [ $self, 'redirect_to', 'accounts', $c->req->captures ],
    ctx => $c,
    field_order => [
      qw / contact_title company_name email address1 address2 address3
           city country post_code telephone mobile fax/ ],
  );

=head1 DESCRIPTION

This subclass of L<Reaction::UI::ViewPort::Object> is used for rendering a
collection of C<Reaction::UI::ViewPort::Field::Mutable::*> objects for user editing.

=head1 ATTRIBUTES

=head2 model

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

L<Reaction::UI::ViewPort::Object>

L<Reaction::UI::ViewPort>

L<Reaction::InterfaceModel::Action>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

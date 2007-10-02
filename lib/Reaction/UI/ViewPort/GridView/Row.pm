package Reaction::UI::ViewPort::GridView::Row;

use Reaction::Class;

class Row is 'Reaction::UI::ViewPort::ObjectView', which {

  around build_fields_for_type_Num => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/number'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_Int => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/number'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_Bool => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/boolean'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };


  around build_fields_for_type_Str => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_SimpleStr => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_Enum => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/string'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_DateTime => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/date_time'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_ArrayRef => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/list'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_Reaction_InterfaceModel_Collection => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/collection'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

  around build_fields_for_type_Reaction_InterfaceModel_Object => sub {
    my ($orig, $self, $attr, $args) = @_;
    $args->{Field}{$attr->name}{layout} = 'value/related_object'
      unless( exists  $args->{Field}{$attr->name}         &&
              exists  $args->{Field}{$attr->name}{layout} &&
              defined $args->{Field}{$attr->name}{layout}
            );
    $orig->($self, $attr, $args);
  };

};

1;

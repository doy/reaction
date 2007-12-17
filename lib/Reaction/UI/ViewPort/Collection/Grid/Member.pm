package Reaction::UI::ViewPort::Collection::Grid::Member;

use Reaction::Class;

Class Member is 'Reaction::UI::ViewPort::Object', which {

  around _build_fields_for_type_Num => sub {
    $_[0]->(@_[1..3], { layout => 'value/number', %{ $_[4] } })
  };

  around _build_fields_for_type_Int => sub {
    $_[0]->(@_[1..3], { layout => 'value/number', %{ $_[4] } })
  };

  around _build_fields_for_type_Bool => sub {
    $_[0]->(@_[1..3], { layout => 'value/boolean', %{ $_[4] } })
  };

  around _build_fields_for_type_Enum => sub {
    $_[0]->(@_[1..3], { layout => 'value/string', %{ $_[4] } })
  };

  around _build_fields_for_type_Str => sub {
    $_[0]->(@_[1..3], { layout => 'value/string', %{ $_[4] } })
  };

  around _build_fields_for_type_SimpleStr => sub {
    $_[0]->(@_[1..3], { layout => 'value/string', %{ $_[4] } })
  };

  around _build_fields_for_type_Reaction_InterfaceModel_Object => sub {
    $_[0]->(@_[1..3], { layout => 'value/string', %{ $_[4] } })
  };

  around _build_fields_for_type_DateTime => sub {
    $_[0]->(@_[1..3], { layout => 'value/date_time', %{ $_[4] } })
  };

  around _build_fields_for_type_Password => sub { return };
  around _build_fields_for_type_ArrayRef => sub { return };
  around _build_fields_for_type_Reaction_InterfaceModel_Collection => sub { return };

};

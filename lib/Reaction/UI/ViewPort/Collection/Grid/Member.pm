package Reaction::UI::ViewPort::Collection::Grid::Member;

use Reaction::Class;

class Member is 'Reaction::UI::ViewPort::Object', which {

  around _build_fields_for_type_Num => sub {
    $_[0]->(@_[1,2], { layout => 'value/number', %{ $_[3] || {}} })
  };

  around _build_fields_for_type_Int => sub {
    $_[0]->(@_[1,2], { layout => 'value/number', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Bool => sub {
    $_[0]->(@_[1,2], { layout => 'value/boolean', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Enum => sub {
    $_[0]->(@_[1,2], { layout => 'value/string', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Str => sub {
    $_[0]->(@_[1,2], { layout => 'value/string', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Reaction_Types_Core_SimpleStr => sub {
    $_[0]->(@_[1,2], { layout => 'value/string', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Reaction_InterfaceModel_Object => sub {
    $_[0]->(@_[1,2], { layout => 'value/string', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Reaction_Types_DateTime_DateTime => sub {
    $_[0]->(@_[1,2], { layout => 'value/date_time', %{ $_[3] || {} } })
  };

  around _build_fields_for_type_Reaction_Types_Core_Password => sub { return };
  around _build_fields_for_type_ArrayRef => sub { return };
  around _build_fields_for_type_Reaction_InterfaceModel_Collection => sub { return };

};

1;

package ComponentUI::View::Site;

use Reaction::Class;
use aliased 'Reaction::UI::View::TT';

class Site is TT, which {

};

1;

__END__;

use Class::MOP;

{
  my @reflect_widgets = qw(ActionForm ObjectView ListView
                           Field::File
                           Field::Password
                           Field::Text        DisplayField::Text
                           Field::Number      DisplayField::Number
                           Field::String      DisplayField::String
                           Field::Boolean     DisplayField::Boolean
                           Field::DateTime    DisplayField::DateTime
                           Field::ChooseOne   DisplayField::RelatedObject
                           Field::ChooseMany  DisplayField::Collection
                           Field::HiddenArray DisplayField::List
                          );


  for (@reflect_widgets){
    my $base = "Reaction::UI::Widget::${_}";
    my $target = "ComponentUI::View::Site::Widget::${_}";
    Class::MOP::load_class( $base );
    $base->meta->create($target, superclasses => [$base]);
  }
}

1;

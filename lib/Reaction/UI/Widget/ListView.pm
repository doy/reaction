package Reaction::UI::Widget::ListView;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::ViewPort::ListView' => 'ListView_VP';

class ListView which {

  has 'viewport' => (isa => ListView_VP, is => 'ro', required => 1);

  widget renders [
    qw(header body) => { viewport => func(self => 'viewport') }
  ];
  
  header renders [ header_entry over func(viewport => 'field_names') ];
  
  header_entry renders [ string { $_{viewport}->field_label_map->{ $_ } } ];
  
  body renders [ row over func(viewport => 'current_page_collection') ];
  
  row renders [
    col_entry over func(viewport => 'field_names') => { row => $_ }
  ];
  
  col_entry renders [
    string {
      my $proto = $_{row}->$_;
      if (blessed($proto) && $proto->can('display_name')) {
        return $proto->display_name;
      }
      return "${proto}";
    }
  ];

};

1;

=head1 NAME

Reaction::UI::Widget::ListView

=head1 DESCRIPTION

=head2 viewport

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

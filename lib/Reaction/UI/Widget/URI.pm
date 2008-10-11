package Reaction::UI::Widget::URI;

use Reaction::UI::WidgetClass;
use namespace::clean -except => [ qw(meta) ];

before fragment widget {
  arg uri => $_{viewport}->uri;
};

implements fragment display_fragment {
  my $vp = $_{viewport};
  return unless $vp->has_display;
  my $display = $vp->display;
  if( blessed($display) && $display->isa('Reaction::UI::ViewPort')){
    arg '_' => $display;
    render 'viewport';
  } else {
    arg string_value => $display;
    render 'display_string';
  }
};

__PACKAGE__->meta->make_immutable;


1;

__END__;

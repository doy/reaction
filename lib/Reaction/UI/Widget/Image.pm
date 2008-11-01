package Reaction::UI::Widget::Image;

use Reaction::UI::WidgetClass;
use namespace::clean -except => [ qw(meta) ];

before fragment widget {
  my $vp = $_{viewport};
  my $attrs = {
    src => $vp->uri,
    ($vp->has_width ? (width => $vp->width) : ()),
    ($vp->has_height ? (height => $vp->height) : ()),
  };
  arg img_attrs => attrs( $attrs );
};

__PACKAGE__->meta->make_immutable;

1;

__END__;

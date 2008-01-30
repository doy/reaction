package Reaction::UI::ViewPort::SiteLayout;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort';

class SiteLayout is ViewPort, which {

  has 'title' => (isa => 'Str', is => 'rw', lazy_fail => 1);

  has 'static_base_uri' => (isa => 'Str', is => 'rw', lazy_fail => 1);

};

1;

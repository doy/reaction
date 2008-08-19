package Reaction::UI::Widget::SiteLayout;

use Reaction::UI::WidgetClass;
use aliased 'Reaction::UI::Widget::Container';
use MooseX::Types::Moose 'HashRef';

use namespace::clean -except => [ qw(meta) ];
extends Container;

after fragment widget {
  arg static_base => $_{viewport}->static_base_uri;
  arg title => $_{viewport}->title;
};

implements fragment meta_info {
  my $self = shift;
  if ( $_{viewport}->meta_info->{'http_header'} ) {
    my $http_header = delete $_{viewport}->meta_info->{'http_header'};
    arg 'http_header' => $http_header;
    render 'meta_http_header' => over [keys %$http_header];
  }
  render 'meta_member' => over [keys %{$_{viewport}->meta_info}];
};

implements fragment meta_http_header {
  arg 'meta_name' => $_;
  arg 'meta_value' => $_{'http_header'}->{$_};
};

implements fragment meta_member {
  arg 'meta_name' => $_;
  arg 'meta_value' => $_{viewport}->meta_info->{$_};
};

__PACKAGE__->meta->make_immutable;


1;

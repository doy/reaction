package Reaction::UI::ViewPort::SiteLayout;

use Reaction::Class;
use aliased 'Reaction::UI::ViewPort';

use namespace::clean -except => [ qw(meta) ];
extends ViewPort;

{
    use Moose::Util::TypeConstraints qw/subtype where coerce from via/;

    my $str_type = subtype 'Str'    => where { 1 };
    my $uri_type = subtype 'Object' => where { $_->isa('URI') };

    coerce $str_type
        => from $uri_type
        => via { "$_[0]" };

    has 'static_base_uri' => (isa => $str_type, coerce => 1, is => 'rw', lazy_fail => 1);

    no Moose::Util::TypeConstraints;
}

has 'title' => (isa => 'Str', is => 'rw', lazy_fail => 1);

has 'meta_info' => (
       is => 'rw', isa => 'HashRef',
       required => '1', default => sub { {} }
);

__PACKAGE__->meta->make_immutable;


1;

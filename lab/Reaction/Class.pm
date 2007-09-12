=head1 NAME

Reaction::Class - Reaction class declaration syntax

=head1 SYNOPSIS

In My/Person.pm:

=for example My::Person setup

  package My::Person;

  use Reaction::Class;
  use Reaction::Types::Core qw/Str/;

  class Person which {

    has 'name' => Str;

    has 'nickname' => optional Str;

    implements 'preferred_name' which {
      accepts nothing;
      returns Str;
      guarantees when { $self->has_nickname } returns { $self->nickname };
      guarantees when { !$self->has_nickname } returns { $self->name };
    } with {
      return ($self->has_nickname ? $self->nickname : $self->name);
    };

  };

=for example My::Person tests

=begin tests

my $meta = My::Person->meta;

isa_ok($meta, 'Reaction::Meta::Class');

my $attr_map = $meta->get_attribute_map;

foreach my $attr_name (qw/name nickname/) {
  isa_ok($attr_map->{$attr_name}, 'Reaction::Meta::Attribute');
}

ok($attr_map->{name}->is_required, 'name is required');
ok(!$attr_map->{nickname}->is_required, 'nickname is optional');

=end tests

In your code -

=for example My::Person usage

  my $jim = My::Person->new(name => 'Jim');

  print $jim->name."\n"; # prints "Jim\n"

  print $jim->preferred_name."\n"; # prints "Jim\n"

  $jim->name('James'); # returns 'James'

  $jim->nickname('Jim'); # returns 'Jim'

  print $jim->preferred_name."\n"; # prints "Jim\n"

  $jim->preferred_name('foo'); # throws Reaction::Exception::MethodArgumentException

=for example My::Person end

=head1 DESCRIPTION

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

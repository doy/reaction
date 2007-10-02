package Reaction::Meta::Attribute;

use Moose;

extends 'Moose::Meta::Attribute';

#is => 'Bool' ? or leave it open
has lazy_fail  =>
    (is => 'ro', reader => 'is_lazy_fail',  required => 1, default => 0);
has lazy_build =>
    (is => 'ro', reader => 'is_lazy_build', required => 1, default => 0);

around _process_options => sub {
    my $super = shift;
    my ($class, $name, $options) = @_;

    my $fail  = $options->{lazy_fail}; #will this autovivify?
    my $build = $options->{lazy_build};

    if ( $fail || $build) {
      confess("You may not use both lazy_build and lazy_fail for one attribute")
        if $fail && $build;
      confess("You may not supply a default value when using lazy_build or lazy_fail")
        if exists $options->{default};

      $options->{lazy} = 1;
      $options->{required} = 1;

      my $builder = ($name =~ /^_/) ? "_build${name}" : "build_${name}";
      $options->{default} =  $fail ?
        sub { confess "${name} must be provided before calling reader" } :
          sub{ shift->$builder };

      $options->{clearer} ||= ($name =~ /^_/) ? "_clear${name}" : "clear_${name}"
        if $build;
    }

    #we are using this everywhere so might as well move it here.
    $options->{predicate} ||= ($name =~ /^_/) ? "_has${name}" : "has_${name}"
      if !$options->{required} || $options->{lazy};


    $super->($class, $name, $options);
};

1;

__END__;

=head1 NAME

Reaction::Meta::Attribute

=head1 SYNOPSIS

    has description => (is => 'rw', isa => 'Str', lazy_fail => 1);

    # OR
    has description => (is => 'rw', isa => 'Str', lazy_build => 1);
    sub build_description{ "My Description" }

    # OR
    has _description => (is => 'rw', isa => 'Str', lazy_build => 1);
    sub _build_description{ "My Description" }

=head1 Method-naming conventions

Reaction::Meta::Attribute will never override the values you set for method names,
but if you do not it will follow these basic rules:

Attributes with a name that starts with an underscore will default to using
builder and predicate method names in the form of the attribute name preceeded by
either "_has" or "_build". Otherwise the method names will be in the form of the
attribute names preceeded by "has_" or "build_". e.g.

   #auto generates "_has_description" and expects "_build_description"
   has _description => (is => 'rw', isa => 'Str', lazy_build => 1);

   #auto generates "has_description" and expects "build_description"
   has description => (is => 'rw', isa => 'Str', lazy_build => 1);

=head2 Predicate generation

All non-required or lazy attributes will have a predicate automatically
generated for them if one is not already specified.

=head2 lazy_fail

=head2 lazy_build

lazy_build will lazily build to the return value of a user-supplied builder sub
 The builder sub will recieve C<$self> as the first argument.

lazy_fail will simply fail if it is called without first having set the value.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

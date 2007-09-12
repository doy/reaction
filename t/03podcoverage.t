use strict;
use warnings;
use Test::More;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => 'Test::Pod::Coverage 1.04 required' if $@;
plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

my @modules = sort { $a cmp $b } (Test::Pod::Coverage::all_modules());
@modules = grep {!/^ComponentUI::/} @modules;
plan tests => scalar(@modules);

# methods to ignore on all modules
my $exceptions = {
  ignore => [
              qw/ BUILD build_ can_ clear_ has_ do_ adopt_ accept_
                  apply_ layout value meta /
            ]
};

foreach my $module (@modules) {
  # build parms up from ignore list
  my $parms = {};
  $parms->{trustme} =
    [ map { qr/^$_/ } @{ $exceptions->{ignore} } ]
    if exists($exceptions->{ignore});

  # run the test with the potentially modified parm set
  pod_coverage_ok($module, $parms, "$module POD coverage");
}

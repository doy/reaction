use inc::Module::Install 0.76;

use 5.008001;

name 'Reaction';
license 'perl';
perl_version '5.008001';
author 'Matt S Trout <mst@shadowcat.co.uk>';
all_from 'lib/Reaction.pm';

requires 'Catalyst' => '5.7002';
requires 'Catalyst::Component::ACCEPT_CONTEXT';
requires 'Catalyst::Component::InstancePerContext' => 0;
requires 'Catalyst::Component::InstancePerContext';
requires 'Catalyst::Model::DBIC::Schema' => 0;
requires 'Catalyst::Plugin::ConfigLoader' => 0.19;
requires 'Catalyst::Plugin::I18N' => 0;
requires 'Catalyst::Plugin::Static::Simple' => 0;
requires 'Catalyst::View::TT' => '0.23';
requires 'Config::General' => 0;
requires 'Crypt::Eksblowfish::Bcrypt';
requires 'DBIx::Class' => '0.07001';
requires 'DBIx::Class::IntrospectableM2M' => '0.001000';
requires 'DateTime';
requires 'DateTime::Event::Recurrence';
requires 'DateTime::Format::MySQL';
requires 'DateTime::Span';
requires 'Devel::Declare' => '0.003004';
requires 'Email::MIME';
requires 'Email::MIME::Creator';
requires 'Email::Send';
requires 'Email::Valid';
requires 'File::ShareDir' => '1.00';
requires 'Moose' => '0.58';
requires 'MooseX::Types' => '0.04';
requires 'MooseX::Types::Common';
requires 'MooseX::Types::DateTime';
requires 'SQL::Translator' => '0.08';
requires 'Scalar::Util';
requires 'Test::Class' => 0;
requires 'Test::Memory::Cycle' => 0;
requires 'Text::CSV_XS';
requires 'Time::ParseDate';
requires 'aliased' => 0;
requires 'namespace::clean' => '0.08';

test_requires 'Test::WWW::Mechanize::Catalyst';

install_share;

install_script glob('script/*.pl');

auto_install;
WriteAll;

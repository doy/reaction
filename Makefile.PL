use inc::Module::Install 0.64;

name 'Reaction';
all_from 'lib/ComponentUI.pm';

requires 'Catalyst' => '5.7002';
requires 'Catalyst::Plugin::ConfigLoader' => 0.19;
requires 'Catalyst::Plugin::Static::Simple' => 0;
requires 'Catalyst::Plugin::I18N' => 0;
requires 'Catalyst::Model::DBIC::Schema' => 0;
requires 'Catalyst::View::TT' => '0.23';
requires 'Catalyst::Component::ACCEPT_CONTEXT' => 0;
requires 'Config::General' => 0;
requires 'Test::Class' => 0;
requires 'Test::Memory::Cycle' => 0;
requires 'DBIx::Class' => '0.07001';
requires 'SQL::Translator' => '0.08';
requires 'Moose' => '0.43';
requires 'aliased' => 0;
requires 'DateTime';
requires 'DateTime::Span';
requires 'DateTime::Event::Recurrence';
requires 'DateTime::Format::MySQL';
requires 'Time::ParseDate';
requires 'Email::Valid';
requires 'Digest::MD5';
requires 'Email::Send';
requires 'Email::MIME';
requires 'Email::MIME::Creator';
requires 'Text::CSV_XS';
requires 'Devel::Declare' => '0.001006';
requires 'MooseX::Types' => '0.04';
requires 'Scalar::Util';
requires 'File::ShareDir';

install_share;

install_script glob('script/*.pl');

auto_install;
WriteAll;

use inc::Module::Install 0.76;

use 5.008001;

name 'Reaction';
license 'perl';
perl_version '5.008001';
author 'Matt S Trout <mst@shadowcat.co.uk>';
all_from 'lib/Reaction.pm';

requires 'Catalyst' => '5.7002';
requires 'Catalyst::Component::ACCEPT_CONTEXT';
requires 'Catalyst::Component::InstancePerContext';
requires 'Catalyst::Model::DBIC::Schema' => 0;
requires 'Catalyst::Plugin::ConfigLoader' => 0.19;
requires 'Catalyst::Plugin::I18N' => 0;
requires 'Catalyst::Plugin::Static::Simple' => 0;
requires 'Catalyst::View::TT' => '0.23';
requires 'Config::General' => 0;
requires 'Crypt::Eksblowfish::Bcrypt'; # lib/Reaction/InterfaceModel/Object/User/Role/ConfirmationCodeSupport.pm
requires 'Class::MOP';
requires 'DBIx::Class' => '0.07001';
requires 'DBIx::Class::IntrospectableM2M' => '0.001000';
requires 'DateTime';
requires 'DateTime::Event::Recurrence';
requires 'DateTime::Span';
requires 'Devel::Declare' => '0.003004';
requires 'Email::Valid';
requires 'File::ShareDir' => '1.00'; #
requires 'File::Spec';
requires 'Moose' => '0.58';
requires 'MooseX::Types' => '0.04';
requires 'MooseX::Types::Common';
requires 'MooseX::Types::DateTime';
requires 'Path::Class::Dir';
requires 'Path::Class::File';
requires 'Scalar::Util';
requires 'Sub::Exporter';
requires 'Sub::Name';
requires 'Template';
requires 'Time::ParseDate';
requires 'URI';
requires 'aliased';
requires 'namespace::clean' => '0.08';
requires 'metaclass';
requires 'Method::Signatures::Simple';
requires 'signatures';

test_requires 'Test::Class';
test_requires 'Test::WWW::Mechanize::Catalyst';
test_requires 'Test::Memory::Cycle';
test_requires 'SQL::Translator' => '0.08'; # for deploy in tests

install_share;

install_script glob('script/*.pl');

auto_install;
WriteAll;

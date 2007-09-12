package RTest::InterfaceModel::DBIC;

use base qw/Reaction::Test::WithDB Reaction::Object/;
use Reaction::Class;
use ComponentUI::TestModel;
use Test::More ();

has '+schema_class' => (default => sub { 'RTest::TestDB' });

has im_schema => (is =>'ro', isa => 'ComponentUI::TestModel', lazy_build => 1);
sub build_im_schema{
  my $self = shift;

  my (@dm) = ComponentUI::TestModel->domain_models;
  Test::More::ok(@dm == 1, 'Correct number of Domain Models');
  my $dm = shift @dm;
  Test::More::ok($dm->name eq '_testdb_schema', 'Domain Model created correctly');

  ComponentUI::TestModel->new($dm->name => $self->schema);
}

sub test_SchemaClass :Tests {
  my $self = shift;
  my $s = $self->im_schema;

  #just make sure here...
  Test::More::isa_ok( $s, 'Reaction::InterfaceModel::Object',
                  'Correctly override default base object' );

  my %pa = map{$_->name => $_ } $s->parameter_attributes;
  Test::More::ok(keys %pa == 3,  'Correct number of Parameter Attributes');

  Test::More::ok($pa{Foo} && $pa{'Bar'} && $pa{'Baz'},
                 'Parameter Attributes named correctly');

  #for now since we have no generic collection object
  Test::More::ok
      ( $pa{Foo}->_isa_metadata eq 'Reaction::InterfaceModel::DBIC::Collection',
        'Parameter Attributes typed correctly' );

  Test::More::is($pa{Baz}->reader, 'bazes', 'Correct Baz reader created');
  Test::More::is($pa{Foo}->reader, 'foo_collection', 'Correct Foo reader created');
  Test::More::is($pa{Bar}->reader, 'bar_collection', 'Correct Bar reader created');

  #is this check good enough? Moose will take care of checking the type constraints,
  # so i dont need tocheck that Moose++ !!
  my $foo1 = $s->foo_collection;
  my $foo2 = $s->foo_collection;
  Test::More::ok
      (Scalar::Util::refaddr($foo1) ne Scalar::Util::refaddr($foo2),
       'Fresh Collections work');
}

sub test_ObjectClass :Tests  {
  my $self = shift;

  my $collection = $self->im_schema->foo_collection;
  Test::More::ok( my $im = $collection->find({ id => 1}), 'Find call successful');

  Test::More::isa_ok( $im, 'ComponentUI::TestModel::Foo',
                  'Correct result class set' );

  my %pa = map{$_->name => $_ } $im->parameter_attributes;
  Test::More::ok(keys %pa == 4,  'Correct number of Parameter Attributes');

  Test::More::is( $pa{first_name}->_isa_metadata, 'NonEmptySimpleStr'
                  ,'Column ParameterAttribute typed correctly');

  Test::More::is
      ($pa{baz_list}->_isa_metadata, 'Reaction::InterfaceModel::DBIC::Collection',
       "Relationship detected successfully");

  my (@dm) = $im->domain_models;
  Test::More::ok(@dm == 1, 'Correct number of Domain Models');
  my $dm = shift @dm;
  Test::More::is($dm->name, '_foo_store', 'Domain Model created correctly');

  my $rs = $collection->_override_action_args_for->{target_model};
  Test::More::isa_ok( $rs, 'DBIx::Class::ResultSet',
                      'Collection target_type ISA ResultSet' );

  my $row = $im->_default_action_args_for->{target_model};
  Test::More::isa_ok( $row, 'DBIx::Class::Row', 'Collection target_type ISA Row' );

  my $ctx = $self->simple_mock_context;

  my $create = $collection->action_for('Create', ctx => $ctx);
  Test::More::isa_ok( $create, 'Reaction::InterfaceModel::Action',
                      'Create action isa Action' );

  Test::More::isa_ok( $create, 'ComponentUI::TestModel::Foo::Action::Create',
                      'Create action has correct name' );

  Test::More::isa_ok
      ( $create, 'Reaction::InterfaceModel::Action::DBIC::ResultSet::Create',
        'Create action isa Action::DBIC::ResultSet::Create' );


  my $update = $im->action_for('Update', ctx => $ctx);
  Test::More::isa_ok( $update, 'Reaction::InterfaceModel::Action',
                      'Update action isa Action' );

  Test::More::isa_ok( $update, 'ComponentUI::TestModel::Foo::Action::Update',
                      'Update action has correct name' );

  Test::More::isa_ok
      ( $update, 'Reaction::InterfaceModel::Action::DBIC::Result::Update',
        'Update action isa Action::DBIC::ResultSet::Update' );

  my $delete = $im->action_for('Delete', ctx => $ctx);
  Test::More::isa_ok( $delete, 'Reaction::InterfaceModel::Action',
                      'Delete action isa Action' );

  Test::More::isa_ok( $delete, 'ComponentUI::TestModel::Foo::Action::Delete',
                      'Delete action has correct name' );

  Test::More::isa_ok
      ( $delete, 'Reaction::InterfaceModel::Action::DBIC::Result::Delete',
        'Delete action isa Action::DBIC::ResultSet::Delete' );


  my $custom = $im->action_for('CustomAction', ctx => $ctx);
  Test::More::isa_ok( $custom, 'Reaction::InterfaceModel::Action',
                      'CustomAction isa Action' );

  Test::More::isa_ok( $custom, 'ComponentUI::TestModel::Foo::Action::CustomAction',
                      'CustomAction has correct name' );

  my %params = map {$_->name => $_ } $custom->parameter_attributes;
  Test::More::ok(exists $params{$_}, "Field ${_} reflected")
      for qw(first_name last_name baz_list);

  #TODO -- will I need a mock $c object or what? I dont really know much about
  # testingcat apps, who wants to volunteer?
  # main things needing testing is attribute reflection
  # and correct action class creation (superclasses)
}


1;

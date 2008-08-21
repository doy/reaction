package ComponentUI::Controller::TestModel::Foo;

use base 'Reaction::UI::Controller::Collection::CRUD';
use Reaction::Class;

__PACKAGE__->config(
  model_name => 'TestModel',
  collection_name => 'Foo',
  action => {
    base => { Chained => '/base', PathPart => 'testmodel/foo' },
    list => {
      ViewPort => {
        excluded_fields => [qw/id/],
      },
    },
    view => {
      ViewPort => {
        excluded_fields => [qw/id/],
      },
    },
  },
);

for my $action (qw/view create update/){
  __PACKAGE__->config(
    action => {
      $action => {
        ViewPort => {
          container_layouts => [
            { name => 'primary', fields => [qw/first_name last_name/]},
            {
              name => 'secondary',
              label => 'Optional Label',
              fields => [qw/bars bazes/],
            },
          ],
        },
      },
    }
  );
}

1;

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
        action_prototypes => { delete_all => 'Delete all records' },
        excluded_fields => [qw/id/],
        action_order => [qw/delete_all create/],
        Member => {
          action_order => [qw/view update delete/],
        },
      },
    },
    view => {
      ViewPort => {
        excluded_fields => [qw/id/],
      },
    },
    delete => {
      ViewPort => {message => 'Are you sure you want to delete this Foo?'}
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

sub _build_action_viewport_args {
  my $self = shift;
  my $args = $self->next::method(@_);
  $args->{list}{action_prototypes}{delete_all}{label} = 'Delete All Records';
  return $args;
}

1;

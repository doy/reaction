package Reaction::UI::ViewPort::ListView;

use Reaction::Class;
use Data::Page;
use Text::CSV_XS;
use Scalar::Util qw/blessed/;

class ListView is 'Reaction::UI::ViewPort', which {
  has collection => (isa => 'DBIx::Class::ResultSet',
                       is => 'rw', required => 1);

  has current_collection => (
    isa => 'DBIx::Class::ResultSet', is => 'rw',
    lazy_build => 1, clearer => 'clear_current_collection',
  );

  has current_page_collection => (
    isa => 'DBIx::Class::ResultSet', is => 'rw',
    lazy_build => 1, clearer => 'clear_current_page_collection',
  );

  has page => (
    isa => 'Int', is => 'rw', required => 1,
    default => sub { 1 }, trigger_adopt('page'),
  );

  has pager => (
    isa => 'Data::Page', is => 'rw',
    lazy_build => 1, clearer => 'clear_pager',
  );

  has per_page => (
    isa => 'Int', is => 'rw', predicate => 'has_per_page',
    default => sub { 10 }, trigger_adopt('page'),
    clearer => 'clear_per_page',
  );

  has field_names => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);

  has field_label_map => (is => 'rw', isa => 'HashRef', lazy_build => 1);

  has order_by => (
    isa => 'Str', is => 'rw', predicate => 'has_order_by',
    trigger_adopt('order_by')
  );

  has order_by_desc => (
    isa => 'Int', is => 'rw', default => sub { 0 },
    trigger_adopt('order_by')
  );

  has row_action_prototypes => (isa => 'ArrayRef', is => 'ro', lazy_build => 1);

  has exclude_columns =>
      ( is => 'rw', isa => 'ArrayRef', required => 1, default => sub{ [] } );

  implements BUILD => as {
    my ($self, $args) = @_;
    if ($args->{unpaged}) {
      $self->clear_per_page;
    }
  };

  sub field_label { shift->field_label_map->{+shift}; }

  implements build_pager => as {
    my ($self) = @_;
    return $self->current_page_collection->pager;
  };

  implements adopt_page => as {
    my ($self) = @_;
    $self->clear_current_page_collection;
    $self->clear_pager;
  };

  implements adopt_order_by => as {
    my ($self) = @_;
    $self->clear_current_collection;
    $self->clear_current_page_collection;
  };

  implements build_current_collection => as {
    my ($self) = @_;
    my %attrs;
    if ($self->has_order_by) {
      $attrs{order_by} = $self->order_by;
      if ($self->order_by_desc) {
        $attrs{order_by} .= ' DESC';
      }
    }
    return $self->collection
                ->search(undef, \%attrs);
  };

  implements build_current_page_collection => as {
    my ($self) = @_;
    my %attrs;
    return $self->current_collection unless $self->has_per_page;
    $attrs{rows} = $self->per_page;
    return $self->current_collection
                ->search(undef, \%attrs)
                ->page($self->page);
  };

  implements all_current_rows => as {
    return shift->current_collection->all;
  };

  implements current_rows => as {
    return shift->current_page_collection->all;
  };

  implements build_field_names => as {
    my ($self) = @_;
    #candidate for future optimization
    my %excluded = map { $_ => undef } @{ $self->exclude_columns };

    return
      $self->sort_by_spec( $self->column_order,
           [ map { (($_->get_read_method) || ()) }
             grep { !($_->has_type_constraint
                      && ($_->type_constraint->is_a_type_of('ArrayRef')
                          || eval { $_->type_constraint->name->isa(
                                      'DBIx::Class::ResultSet') })) }
             grep { !exists $excluded{$_->name} }
             grep { $_->name !~ /^_/ }
               $self->current_collection
                    ->result_class
                    ->meta
                    ->compute_all_applicable_attributes
           ] );
  };

  implements build_field_label_map => as {
    my ($self) = @_;
    my %labels;
    foreach my $name (@{$self->field_names}) {
      $labels{$name} = join(' ', map { ucfirst } split('_', $name));
    }
    return \%labels;
  };

  implements build_row_action_prototypes => as {
    my $self = shift;
    my $ctx = $self->ctx;
    return [
      { label => 'View', action => sub {
        [ '', 'view', [ @{$ctx->req->captures}, $_[0]->id ] ] } },
      { label => 'Edit', action => sub {
        [ '', 'update', [ @{$ctx->req->captures}, $_[0]->id ] ] } },
      { label => 'Delete', action => sub {
        [ '', 'delete', [ @{$ctx->req->captures}, $_[0]->id ] ] } },
    ];
  };

  implements row_actions_for => as {
    my ($self, $row) = @_;
    my @act;
    my $c = $self->ctx;
    foreach my $proto (@{$self->row_action_prototypes}) {
      my %new = %$proto;
      my ($c_name, $a_name, @rest) = @{delete($new{action})->($row)};
      $new{label} = delete($new{label})->($row) if ref $new{label} eq 'CODE';
      $new{uri} = $c->uri_for(
                    $c->controller($c_name)->action_for($a_name),
                    @rest
                  );
      push(@act, \%new);
    }
    return \@act;
  };

  implements export_to_csv => as {
    my ($self) = @_;
    my $csv = Text::CSV_XS->new( {  binary => 1 } );
    my $output;
    my $exporter = sub {
      $csv->combine( @_ );
      $output .= $csv->string."\r\n";
    };
    $self->export_to_data($exporter);
    my $res = $self->ctx->res;
    $res->content_type('text/csv');
    my $path = $self->ctx->req->path;
    my @parts = split(/\//, $path);
    $res->header(
      'Content-disposition' => 'attachment; filename='.pop(@parts).'.csv'
    );
    $res->body($output);
  };

  implements export_to_data => as {
    my ($self, $exporter) = @_;
    $self->export_header_data($exporter);
    $self->export_body_data($exporter);
  };

  implements export_header_data => as {
    my ($self, $exporter) = @_;
    my @names = @{$self->field_names};
    my %labels = %{$self->field_label_map};
    $exporter->( map { $labels{$_} } @names );
  };

  implements export_body_data => as {
    my ($self, $exporter) = @_;
    my @names = @{$self->field_names};
    foreach my $row ($self->all_current_rows) {
      my @row_data;
      foreach $_ (@names) {
        my $data = $row->$_;
        if (blessed($data) && $data->can("display_name")) {
          $data = $data->display_name;
        }
        push(@row_data, $data);
      }
      $exporter->( @row_data );
    }
  };

  override accept_events => sub { ('page', 'order_by', 'order_by_desc', 'export_to_csv', super()); };

};

1;

=head1 NAME

Reaction::UI::ViewPort::ListView - Page layout block for rows of DBIx::Class::ResultSets

=head1 SYNOPSIS

  # Create a new ListView
  # $stack isa Reaction::UI::FocusStack object
  # Assuming you have a DBIC model with an Actors table
  my $lv = $stack->push_viewport(
    'Reaction::UI::ViewPort::ListView',
    collection => $ctx->model('DBIC::Actors'),     # a DBIx::Class::ResultSet
    page => 1,                                     # 1 is default
    per_page => 10,                                # 10 is default
    field_names => [qw/name age/],
    field_label_map => {
      'name' => 'Name',
      'age' => 'Age',
    },
    order_by => 'name',
  );

=head1 DESCRIPTION

Use this ViewPort to display the contents of a
L<DBIx::Class::ResultSet> as paged sets of rows. The default display
shows 10 rows per page, unsorted.

TODO: Add a filter_by which allows us to restrict the content?
(Scenario: user has a paged display of data, user selects one value in
a column and clicks "filter by this value", and then only rows
containing that value are shown.

=head1 ATTRIIBUTES

=head2 collection

This mandatory attribute must be an object derived from
L<DBIx::Class::ResultSet> representing the search result or result
source(Table) you wish to display in the ListView.

The collection is used as the basis to create a refined set of data to
show in the current ListView, this is stored in
L<current_collection>. The data can further be refined and restricted
by passing in or later changing the L<order_by> or L<page>
attributes. The

=head2 order_by

A string representing the C<ORDER BY> part of the SQL statement, for
more info see L<DBIx::Class::ResultSet/Attributes>

=head2 order_by_desc

By default, sorting is done in ascending order, set this to true to
sort in descending order. Changing this attribute will cause the
L<current_collection> to be cleared and recreated on the next access .

=head2 exclude_columns



=head2 page

The page number of the current search result, this will default to
1. If set explicitly on the ListView object, the current search result
and the pager will be cleared and recreated on the next access.

=head2 per_page

The number of rows of data to list on each page. Changing this value
on the ListView object will cause the L<current_page_collection> and
the L<pager> to be cleared and recreated on the next access. This will
default to 10 if unset.

=head2 unpaged

Set this to a true value if you really don't want your results shown
in pages.

=head2 field_names

An array reference of field names to show in the ListView. These must
exist as accessors in the L<DBIx::Class::ResultSource> describing the
L<DBIx::Class::ResultSet> passed to L<collection>.

If not set, this will default to the list of attributes in the
L<DBIx::Class::ResultSource> which do not begin with an underscore,
and don't have a type of either ArrayRef or
C<DBIx::Class::ResultSet>. In short, all the non-private and
non-relation attributes.

=head2 field_label_map

A hash reference mapping the L<field_names> to the column labels used
to describe them in the ListView display.

If not set, the label values will default to the L<field_names> with
the initial characters capitalised and underscores turned into spaces.

=head2 row_action_prototypes

  row_action_prototypes => [
    { label => 'Edit', action => sub { [ '', 'update', [ $_[0]->id ] ] } },
    { label => 'Delete', action => sub { [ '', 'delete', [ $_[0]->id ] ] } },
  ];

Prototypes describing the actions that can be done on the rows of
ListView data. This is an array reference of hash refs describing the
name of each action with a C<label>, and the actual C<action> that
takes place. The code reference stored in the C<action > will be
called with a L<DBIx::Class::Row> object, it should return a list of a
L<Catalyst::Controller> name, the name of an action in that
controller, and any other parameters that need to be passed to
it. C<label> may be a scalar value or a code reference, in the later case
it will be called with the same parameters as C<action> and the return value
will be used as the C<label> value.

The example above shows the default actions if this attribute is not set.

=head2 current_collection

This contains the currently used L<DBIx::Class::ResultSet>
representing the ListViews data, it is based on the L<collection>
ResultSet, refined using the L<order_by> and L<order_by_desc> attributes.

The current_collection will be cleared and recreated if the
L<order_by> or L<order_by_desc> attributes are changed on the ListView
object.

=head2 current_rows

=head2 all_current_rows

=head2 pager

A L<Data::Page> object representing the data for the current search
result, it is cleared and reset when either L<page> or L<order_by> are
changed.

=head2 current_page_collection

This contains contains a single page of the contents of the
L<current_collection>, with the L<per_page> number of rows
requested. If the L<page>, L<per_page>, L_order_by> or
L<order_by_desc> attributes are changed on the ListView object, the
current_page_collection is cleared and recreated.

=head1 METHODS

=head2 row_actions_for

=over 4

=item Arguments: none

=back

Returns an array reference of uris and labels representing the actions
set in L<row_action_prototypes>. L<Catalyst/uri_for> is used to
construct these.

=head2 export_header_data

=over 4

=item Arguments: $exporter

=back

  $lv->export_head_data($exporter);

C<$exporter> should be a code reference which will export lists of
data passed to it. This method calls the C<exporter> code reference
passing it the labels from the L<field_label_map> using the current
set of L<field_names>.

=head2 export_body_data

=over 4

=item Arguments: $exporter

=back

  $lv->export_body_data($exporter);

C<$exporter> should be a code reference which will export lists of
data passed to it. This method calls the C<exporter> code reference
with an array of rows containing the data values of each of the
current L<field_values>.

=head2 export_to_data

=over 4

=item Arguments: $exporter

=back

  $lv->export_to_data($exporter);

C<$exporter> should be a code reference which will export lists of
data passed to it. This method calls L<export_header_data> and
L<export_body_data> with C<exporter>.

=head2 export_to_csv

=over 4

=item Arguments: none

=back

  $lv->export_to_csv();

Fills the L<Catalyst::Response> body with CSV data of the
L<current_collection> using L<export_to_data> and L<Text::CSV_XS>.

=head2 field_label

=over 4

=item Arguments: $field_name

=back

Returns the label for the given C<field_name>, using L<field_label_map>.

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package Reaction::InterfaceModel::Action::DBIC::ActionReflector;

use Reaction::Class;

use aliased 'Reaction::InterfaceModel::Action::DBIC::ResultSet::Create';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Update';
use aliased 'Reaction::InterfaceModel::Action::DBIC::Result::Delete';

class ActionReflector which {

  #this will break with immutable. need to port back from dbic::objectclass
  implements reflect_action_for => as {
    my ($self, $class, $action_class, $action, $super, $attrs ) = @_;

    my $str = "package ${action_class};\nuse Reaction::Class;\n";
    eval $str;
    confess "Error making ${action_class} a Reaction class: $@" if $@;
    warn $str if $ENV{REACTION_DEBUG};
    my $types = $self->reflect_action_types;
    if( exists $types->{$action} ){ #get defaults if action is a builtin
        my ($conf_super, $conf_attrs) = @{$types->{$action}};
        $super ||= $conf_super;
        $attrs ||= $conf_attrs;
    }
    $super = [ $super ] unless ref($super) eq 'ARRAY';
    $action_class->can('extends')->(@$super);
    warn "extends ".join(', ', map { "'$_'" } @$super).";\n"
      if $ENV{REACTION_DEBUG};
    $attrs ||= [];
    if ($attrs eq '*') {
        $self->reflect_all_writable_attrs($class => $action_class);
    } elsif (ref $attrs eq 'ARRAY' && @$attrs) {
        $self->reflect_attrs($class => $action_class, @$attrs);
    }
    $action_class->can('register_inc_entry')->();
  };

  implements reflect_actions_for => as {
    my ($self, $class, $reflected_prefix) = @_;
    foreach my $action ( keys %{ $self->reflect_action_types } ) {
      my @stem_parts = split('::', $class);
      my $last_part = pop(@stem_parts);
      my $action_class = "${reflected_prefix}::${action}${last_part}";
      $self->reflect_action_for($class, $action_class, $action);
    }
  };

  implements reflect_all_writable_attrs => as {
    my ($self, $from_class, $to_class) = @_;
    my $from_meta = $from_class->meta;
    foreach my $from_attr ($from_meta->compute_all_applicable_attributes) {
      next unless $from_attr->get_write_method;
      $self->reflect_attribute_to($from_class, $from_attr, $to_class);
    }
  };

  implements reflect_attrs => as {
    my ($self, $from_class, $to_class, @attrs) = @_;
    foreach my $attr_name (@attrs) {
      $self->reflect_attribute_to
          ($from_class,
           $from_class->meta->find_attribute_by_name($attr_name),
           $to_class);
    }
  };

  implements reflect_attribute_to => as {
    my ($self, $from_class, $from_attr, $to_class) = @_;
    my $attr_name = $from_attr->name;
    my $to_meta = $to_class->meta;
    my %opts; # = map { ($_, $from_attr->$_) } qw/isa is required/;
    my @extra;
    @opts{qw/isa is/} =
      map { my $meth = "_${_}_metadata"; $from_attr->$meth; }
      qw/isa is/;
    if ($from_attr->is_required) {
      if(defined $from_attr->default){
        @opts{qw/required default lazy/} = (1, $from_attr->default, 1);
      } else {
          %opts = (%opts, set_or_lazy_fail($from_attr->name));
        push(@extra, qq!set_or_lazy_fail('@{[$from_attr->name]}')!);
      }
    }
    $opts{predicate} = "has_${attr_name}";

    if (my $info = $from_class->result_source_instance
                              ->relationship_info($attr_name)) {
      if ($info->{attrs}->{accessor} && $info->{attrs}->{accessor} eq 'multi') {
        confess "${attr_name} is multi and rw. we are confoos."; # XXX
      } else {
        $opts{valid_values} = sub {
          $_[0]->target_model
               ->result_source
               ->related_source($attr_name)
               ->resultset;
        };
        push(@extra, qq!valid_values => sub {
    \$_[0]->target_model
         ->result_source
         ->related_source('${attr_name}')
         ->resultset;
    }!);
      }
    } elsif ($from_attr->type_constraint->name eq 'ArrayRef'
          || $from_attr->type_constraint->is_subtype_of('ArrayRef')) {
      # it's a many-many. time for some magic.
      ($attr_name =~ m/^(.*)_list$/)
        || confess "Many-many attr must be called <name>_list for reflection";
      my $mm_name = $1;
      my ($hm_source, $far_side);
      my $source = $from_class->result_source_instance;
      eval { $hm_source = $source->related_source("links_to_${mm_name}_list"); }
        || confess "Can't find links_to_${mm_name}_list has_many for ${mm_name}_list";
      eval { $far_side = $hm_source->related_source($mm_name); }
        || confess "Can't find ${mm_name} belongs_to on ".$hm_source->result_class
                   ." traversing many-many for ${mm_name}_list";
      $opts{default} = sub { [] };
      push(@extra, qq!default => sub { [] }!);
      $opts{valid_values} = sub {
        $_[0]->target_model
             ->result_source
             ->related_source("links_to_${mm_name}_list")
             ->related_source(${mm_name})
             ->resultset;
      };
      push(@extra, qq!valid_values => sub {
    \$_[0]->target_model
         ->result_source
         ->related_source('links_to_${mm_name}_list')
         ->related_source('${mm_name}')
         ->resultset;
    }!);
    }
    next unless $opts{is} eq 'rw';
    $to_meta->_process_attribute($from_attr->name => %opts);
    warn "has '".$from_attr->name."' => (".join(', ',
      (map { exists $opts{$_} ? ("$_ => '".$opts{$_}."'") : () }
        qw/isa is predicate/),
      @extra)
      .");\n" if $ENV{REACTION_DEBUG};
  };

  implements reflect_action_types => as {
    return {
      'Create' => [ Create, '*' ],
      'Update' => [ Update, '*' ],
      'Delete' => [ Delete ],
    }
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::DBIC::ActionReflector

=head1 DESCRIPTION

=head2 Create

=head2 Update

=head2 Delete

=head1 METHODS

=head2 reflect_action_for

=head2 reflect_action_types

=head2 reflect_actions_for

=head2 reflect_all_writable_attrs

=head2 reflect_attribute_to

=head2 reflect_attrs

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

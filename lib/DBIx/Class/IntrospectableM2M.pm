package DBIx::Class::IntrospectableM2M;

use strict;
use warnings;
use base 'DBIx::Class';

#namespace pollution. sadface.
__PACKAGE__->mk_classdata( _m2m_metadata => {} );

sub many_to_many {
  my $class = shift;
  my ($meth_name, $link, $far_side) = @_;

  $class->_m2m_metadata->{$meth_name} =
    {
     accessor => $meth_name, 
     relation => $link, #"link" table or imediate relation
     foreign_relation => $far_side, #'far' table or foreign relation
     (@_ > 3 ? (attrs => $_[3]) : ()), #only store if exist
     rs_method => "${meth_name}_rs",      #for completeness..
     add_method => "add_to_${meth_name}",
     set_method => "set_${meth_name}",
     remove_method => "remove_from_${meth_name}",
    };

  $class->next::method(@_);
}

1;

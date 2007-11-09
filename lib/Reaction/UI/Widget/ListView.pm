package Reaction::UI::Widget::ListView;

use Reaction::UI::WidgetClass;

class ListView is 'Reaction::UI::Widget::GridView', which {
  fragment widget [ qw/pager header body footer actions/,
                   {
                    pager               => sub{ $_{viewport}->pager },
                    object_action_count => sub{ $_{viewport}->object_action_count },
                    #^^  it's ugly, i know, but i gotsto
                   }
                 ];

  fragment pager
    [ qw/first_page previous_page current_page next_page last_page page_list/,
      {
       first_page    => sub{ $_{pager}->first_page    },
       previous_page => sub{ $_{pager}->previous_page || $_{pager}->last_page },
       current_page  => sub{ $_{pager}->current_page  },
       next_page     => sub{ $_{pager}->next_page || $_{pager}->first_page },
       last_page     => sub{ $_{pager}->last_page     },
       page_list     => sub{ [$_{pager}->first_page .. $_{pager}->last_page] },
      }
    ];

  fragment first_page    [ string{ "First" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{first_page} } )    } };

  fragment previous_page [ string{ "Previous" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{previous_page} } ) } };

  fragment current_page  [ string{ "Current" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{current_page} } )  } };

  fragment next_page     [ string{ "Next" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{next_page} } )     } };

  fragment last_page     [ string{ "Last" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{last_page} } )     } };

  fragment page_list [ page => over $_{page_list} ];
  fragment page      [ string{ $_ } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_ } ) } };

  fragment actions [ action => over func(viewport => 'actions') ];
  fragment action  [ 'viewport' ];

  fragment header_cell [ string { $_{labels}->{$_} } ],
    { uri => sub{
        my $ev = {order_by => $_, order_by_desc => $_{viewport}->order_by_desc ? 0 : 1 };
        return $_{self}->connect_uri($ev);
      }
    };

  fragment footer_cell [ string { $_{labels}->{$_} } ],
    { uri => sub{
        my $ev = {order_by => $_, order_by_desc => $_{viewport}->order_by_desc ? 0 : 1 };
        return $_{self}->connect_uri($ev);
      }
    };

  #this needs to be cleaned up and moved out
  implements connect_uri => as{
    my ($self, $events) = @_;
    my $vp   = $self->viewport;
    my $ctx  = $self->viewport->ctx;
    my %args = map{ $vp->event_id_for($_) => $events->{$_} } keys %$events;
    return $ctx->req->uri_with(\%args);
  };

};

1;

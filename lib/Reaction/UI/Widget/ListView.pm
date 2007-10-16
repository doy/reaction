package Reaction::UI::Widget::ListView;

use Reaction::UI::WidgetClass;

class ListView is 'Reaction::UI::Widget::GridView', which {
  widget renders [ qw/pager header body footer actions/,
                   {
                    pager               => sub{ $_{viewport}->pager },
                    object_action_count => sub{ $_{viewport}->object_action_count },
                    #^^  it's ugly, i know, but i gotsto
                   }
                 ];

  pager  renders
    [ qw/first_page previous_page current_page next_page last_page page_list/,
      {
       first_page    => sub{ $_{pager}->first_page    },
       previous_page => sub{ $_{pager}->previous_page },
       current_page  => sub{ $_{pager}->current_page  },
       next_page     => sub{ $_{pager}->next_page     },
       last_page     => sub{ $_{pager}->last_page     },
       page_list     => sub{ [$_{pager}->first_page .. $_{pager}->last_page] },
      }
    ];

  first_page    renders [ string{ "First" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{first_page} } )    } };

  previous_page renders [ string{ "Previous" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{previous_page} } ) } };

  current_page  renders [ string{ "Current" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{current_page} } )  } };

  next_page     renders [ string{ "Next" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{next_page} } )     } };

  last_page     renders [ string{ "Last" } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_{last_page} } )     } };

  page_list renders [ page over $_{page_list} ];
  page      renders [ string{ $_ } ],
    { uri => sub{ $_{self}->connect_uri( {page => $_ } ) } };

  actions renders [ action over func(viewport => 'actions') ];
  action  renders [ 'viewport' ];

  header_cell renders [ string { $_{labels}->{$_} } ],
    { uri => sub{
        my $ev = {order_by => $_, order_by_desc => $_{viewport}->order_by_desc ? 0 : 1 };
        return $_{self}->connect_uri($ev);
      }
    };

  footer_cell renders [ string { $_{labels}->{$_} } ],
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

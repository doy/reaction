package Reaction::UI::Widget::ActionForm;

use Reaction::UI::WidgetClass;

class ActionForm, which {
  widget renders [qw/header fields buttons footer/
                  => { viewport => func('self','viewport') } ];

  fields renders [viewport over func('self','ordered_fields')];

  buttons renders [ string {"DUMMY"} ], {message => func('viewport','message');
  header  renders [ string {"DUMMY"} ];
  footer  renders [ string {"DUMMY"} ];

};

1;

__END__;

=for layout widget

  <form action="" method="post" enctype="multipart/form-data">
    [% header  %]
    [% fields  %]
    [% buttons %]
    [% footer  %]
  </form>

=for layout header

<h2>Le Header</h2>

=for layout fields

[% content %] <br />

=for layout buttons

  [% IF message; %]
    <span>[% message %]</span> <br />
  [% END; %]

  [% allowed_events = viewport.accept_events; %]
  [% IF allowed_events.grep('^ok$').size; %]
    <input type="submit" name="[% viewport.event_id_for('ok')    | html%]" value="ok" />
  [% END; %]

  [% IF (viewport.ordered_fields.size != 0) && allowed_events.grep('^apply$').size; %]
    <input type="submit" name="[% viewport.event_id_for('apply') | html%]" value="apply" />
  [% END; %]

  [% IF allowed_events.grep('^close$').size; %]
    <input type="submit" name="[% viewport.event_id_for('close') | html%]" value="cancel" />
  [% END; %]
  <br />

=for layout footer

  <h2>Le Footer</h2>

=cut

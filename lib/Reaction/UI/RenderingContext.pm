package Reaction::UI::RenderingContext;

use Reaction::Class;

class RenderingContext which {

  implements 'render' => as {
    confess "abstract method";
  };

};

1;

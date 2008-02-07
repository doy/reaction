package Reaction::InterfaceModel::Action::User::ResetPassword;

use Reaction::Class;
use Digest::MD5;

use aliased
  'Reaction::InterfaceModel::Action::User::Role::ConfirmationCodeSupport';
use aliased 'Reaction::InterfaceModel::Action::User::SetPassword';

use Reaction::Types::Core qw(NonEmptySimpleStr);

class ResetPassword is SetPassword, which {

  does ConfirmationCodeSupport;

  has confirmation_code => 
      (isa => NonEmptySimpleStr, is => 'rw', lazy_fail => 1);
  
  around error_for_attribute => sub {
    my $super = shift;
    my ($self, $attr) = @_;
    if ($attr->name eq 'confirmation_code') {
      return "Confirmation code incorrect"
        unless $self->verify_confirmation_code;
    }
    #return $super->(@_); #commented out because the original didn't super()
  };
  
  implements verify_confirmation_code => as {
    my $self = shift;
    return $self->has_confirmation_code
        && ($self->confirmation_code eq $self->generate_confirmation_code);
  };

};

1;

=head1 NAME

Reaction::InterfaceModel::Action::User::ResetPassword

=head1 DESCRIPTION

=head2 error_for_attribute

=head2 confirmation_code

=head2 verify_confirmation_code

=head1 SEE ALSO

L<Reaction::InterfaceModel::Action::DBIC::User::ResetPassword>

L<Reaction::InterfaceModel::Action::User::Role::ConfirmationCodeSupport>

=head1 AUTHORS

See L<Reaction::Class> for authors.

=head1 LICENSE

See L<Reaction::Class> for the license.

=cut

package ChatBot::Core::Proxy::Safe;

use 5.006;
use strict;
use warnings;
use ChatBot::Core::Proxy;

our @ISA =qw/ChatBot::Core::Proxy/;
our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Proxy::Safe - Perl extension for ChatBot.

=head1 SYNOPSIS

  use ChatBot::Core::Proxy::Safe;

=head1 DESCRIPTION

Stub documentation for ChatBot::Core::Proxy::Safe, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub
unedited.

=head1 METHODS

=over 4

=item access

return I<safe> access mode.

=cut

 sub access {
	return "Safe";
 }

=item message_orign

Return original message.

=cut
 
 sub message_orign {
	my $self = shift;
	return $self->{MESSAGE}->orig;
 }

=item message_text 

Return text message

=cut

 sub message_text {
	my $self = shift;
	return $self->{MESSAGE}->text;
 }

 sub message_time {
	my $self = shift;
	return $self->{MESSAGE}->time;
 }

=item message_autor

=cut

 sub message_autor {
	my $self = shift;
	return $self->{MESSAGE}->user;
 }

1;
__END__

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=cut

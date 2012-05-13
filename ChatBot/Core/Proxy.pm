package ChatBot::Core::Proxy;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Proxy - Perl extension for Chat-Bot

=head1 SYNOPSIS

=head1 DESCRIPTION

C<ChatBot::Core::Proxy> is a class 

=head1 CONSTRUCTOR

=over 4

=item new ($channel);

=back

=cut

 sub new {
 	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self  = {};
	bless ($self, $class);
	$self->_init(@_) if (@_);
	return $self;
 }

 sub _init {
	my ($self, $message, $channel) = @_;
	$self->{CHANNEL} = $channel;
	$self->{MESSAGE} = $message;
	return $self;
 }
 
=head1 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 4

=item access

Return access level

=cut

 sub access {
	return 'abstract';
 }

 sub send {
	return;
 }

1;
__END__

=head1 AUTHOR

Novgorodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=cut

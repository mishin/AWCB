package ChatBot::Core::Message;

use 5.006;
use strict;
use warnings;
use ChatBot::Core::Message::Reader;
use ChatBot::Core::Message::Parser;
use ChatBot::Core::Message::Sender;

use Data::Dumper;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Message - Perl extension for Chat-Bot

=head1 SYNOPSIS

 use ChatBot::Core::Message;

=head1 DESCRIPTION

C<ChatBot::Core::Message> include: 

=over 2

=item L<ChatBot::Core::Message::Reader>

Модуль I<Reader> является составной частью бB<о>льшего модуля Messages. Данный модуль является родителем или прототипом для пользовательских модулей, отвечающих за получение сообщений системой из вне.

=item L<ChatBot::Core::Message::Parser>

Модуль I<Parser> так же является составной частью бB<о>льшего модуля Messages. Данный модуль является родителем или прототипом для пользовательских модулей, отввечающих за преобразование полученых сообщений в требуемую структуру.

=back

=head1 CONSTRUCTOR

=over 4

=item new 

=back

=cut

 sub new {
	my $class = shift;
	my $self  = {};
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

 sub _init {
 	my ($self, $data) = @_;
	$self->{READER} = 
		ChatBot::Core::Message::Reader->new($data);
	$self->{PARSER} = ChatBot::Core::Message::Parser->new;
	$self->{SENDER} = 
		ChatBot::Core::Message::Sender->new($data);
	return; #abstract
 }
 
=head1 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 4

=item get_new_message

Return new message from driver.

=cut

 sub get_new_message {
	my $self = shift;
	my $new_message = $self->{READER}->read_message;
	return unless $new_message;
	return 'false' unless $new_message =~ m/^'(?:[^']+)'\s(u|s)/;
	my $mes = $self->{PARSER}->parse ($new_message);
	return $mes;
 }

=item send_nem_message ('channel name', 'message text')

Sending new message.

=cut

 sub send_new_message {
	my ($self, $channel, $message) = @_;
	$self->{SENDER}->_init($channel);
	$self->{SENDER}->send_message($message);
	return;
 }

 sub logout {
	my $self = shift;
	$self->{SENDER}->logout;
	return;
 }
1;
__END__

=head1 AUTHOR

Novgorodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=cut

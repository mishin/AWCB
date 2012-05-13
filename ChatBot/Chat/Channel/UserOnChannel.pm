package ChatBot::Chat::Channel::UserOnChannel;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Chat::Channel::UserOnChannel - Perl extension for AWCB

=head2 SYNOPSIS

  use ChatBot::Chat::Channel::UserOnChannel;

  my $user = ChatBot::Chat::Channel::UserOnChannel->new ($user[, 'user flags']);

=head2 DESCRIPTION

C<ChatBOt::Chat::Channel::UserOnChannel> это класс описывающий пользователя на канале. 

=cut

=head2 CONSTRUCTOR

=over 8

=item new (ссылка на объект "пользователь"[, флаги пользователя])

Конструктор создает и возвращает новый объект "пользователя на канале". В качестве первого аргумента необходимо передавать ссылку на объект пользователь. Это необходимо по тому, что данный класс делигирует методы этого объекта.

=back

=cut

 sub new {
 	my $class = shift;
	my $self  = {
		USER => undef,
		FLAGS=> undef
	};
	bless ($self, $class);
	$self->_unhide(@_) if @_;
	return $self;
 }

 sub _unhide {
	my ($self, $user, $flags) = @_;
	$self->{USER} = $user;
	$self->_set_flags($flags);
	return $self;
 }

=head2 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 8

=item _set_flags (флаг(и) пользователя)

Добавляет флаг(и) пользователя.

=cut

 sub _set_flags {
	my ($self, $flags) = @_;
	$self->{FLAGS} = $flags;
	return $self;
 }

=item flags 

Этот метод вовзращает список флагов пользователя.

=cut

 sub flags {
	my $self = shift;
	return $self->{FLAGS};
 }

=item name

Этот метод возвращает имя пользователя.

=cut

 sub name {
 	my $self = shift;
	return $self->{USER}->name;
 }

=item ip

Этот метод возвращает ip-адрес пользователя.

=back

=cut

 sub ip {
	my $self = shift;
	return $self->{USER}->ip;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut

package ChatBot::Chat::Channel;

use 5.006;
use strict;
use warnings;
use ChatBot::Chat::Channel::UserOnChannel;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Chat::Channel - Perl extension for AWCB

=head2 SYNOPSIS

  use ChatBot::Chat::Channel;

  my $channel = ChatBot::Chat::Channel->new;
  $channel->new ('channel name','channel flags');
  $channel->unhide('channel name', 'user name', 'flags');
  $channel->hide('channel name','user name');
  my $channel_name  = $channel->name;
  my @channel_flags = $channel->flag;
  my @channel_users = $channel->users;
  $channel->_add_flag(''channel flag);
  $channel->_add_moderator('moderator name');
  $channel->_add_operator('operator name');

=head2 DESCRIPTION

C<ChatBot::Chat::Channel> это класс, отвечающий за образ "канала". При его создании уточняется название канала, его флаги, списко модераторов и операторов канала. 

=head2 CONSTRUCTOR

=over 8

=item new (название канала[, флаг(и) канала[, список модераторов[, список операторов]]])

Создает образ канала. При создании образа необходимо указать его название, остальные парамерты не обязательно. Важно помнить, что если не указывать, на пример, флаги канал, но указать список модераторов, вместо флагов необходимо указать значение C<undef>. Если модераторов и/или операторов на канале несколько, то необходимо передавать ссылку на списки.

=back

=cut

 sub new {
 	my $class = shift;
	my $self = {
		NAME => undef,
		FLAGS=> undef,
		USER_ON_CHANNEL => {},
		MODERATORS => [],
		OPERATORS => []
	};
	bless ($self, $class);
	$self->_create_channel(@_) if @_;
	return $self;
 }

 sub _create_channel {
	my ($self, $name, $flags, $moderator, $operator) = @_;
	$self->{NAME} = $name;
	$self->_add_flags($flags) if ($flags);
	if (ref($operator) eq 'ARRAY') {
		foreach my $oper (@$operator) {
			$self->_add_operator($oper);
		}
	}
	else {
		$self->_add_operator($operator) if ($operator);
	}
	if (ref($moderator) eq 'ARRAY') {
		foreach my $moder (@$moderator) {
			$self->_add_moderator($moder);
		}
	}
	else {
		$self->_add_moderator($moderator) if ($moderator);
	}
	return $self;
 }


=head2 METHODS


All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).


=over 8

=item name

Этот метод возвращает название канала.

=cut

 sub name {
	my $self = shift;
	return $self->{NAME};
 }

=item _add_flag (флаг(и) канала)

Уточняет флаг(и) канала.

=cut

 sub _add_flag {
	my ($self, $flags) = @_;
	push @{$self->{FLAGS}}, $flags;
	return $self;
 }

=item flags

Этот метод возвращает флаги канала.

=cut

 sub flags {
	my $self = shift;
	return @{$self->{FLAGS}};
 }

=item unhide (ссылка на объект "пользователь"[, флаги пользователя])

Этот метод создает новый объект "пользователь на канале" и сохраняет его в списке пользоватлей присутсвующих на канале. 

=cut

 sub unhide {
	my ($self, $user, $flags) = @_;
	my $user_on_channel = ChatBOt::Chat::Channel::UserOnChannel->new($user, $flags);
	$self->{USER_ON_CHANNEL}->{lc($user_on_channel->name)} = $user_on_channel;
	return $self;
 }
 
=item hide (имя пользователя)

Этот метод удаляет пользователя из списка пользователей на канале.

=cut
 
 sub hide {
	my ($self, $name) = @_;
	delete $self->{USER_ON_CHANNEL}->{lc($name)};
	return;
 }

=item users 

Этот метод возвращает список ссылок на объекты "пользователь на канале".

=cut

 sub users {
	my $self = shift;
	return values %{$self->{USER_ON_CHANNEL}};
 }

=item _add_moderator (имя пользователя(пользователей))

Этот метод добавляет пользователя или пользователей в список модераторов канала.Не обязательно, что бы пользователь в данный момент находился в чате.

=cut

 sub _add_moderator {
	my ($self, $moderator) = @_;
	push @{$self->{MODERATORS}}, $moderator;
	return;
 }

=item _add_opertator (имя пользователя(пользователей))

Добавляет пользователя или пользователей в списко операторов данного канала. Не обязательно, что бы пользователь находился в чате в данны момент.

=back

=cut

 sub _add_operator {
	my ($self, $operator) = @_;
	push @{$self->{OPERATORS}}, $operator;
	return;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novogorodcev<lt>cybivg@gmail.comE<gt>

=cut

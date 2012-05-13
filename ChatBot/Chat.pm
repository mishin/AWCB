package ChatBot::Chat;

use 5.006;
use strict;
use warnings;
use ChatBot::Chat::User;
use ChatBot::Chat::Channel;

our $VERSION = '0.01';

=head1 NAME

ChatBOt::Chat - Perl extension for AWCB

=head2 SYNOPSIS

  use ChatBot::Chat;

  my $chat = ChatBot::Chat->new;
  my $user = $chat->login('user name', 'user ip');
  my $channel = $chat->create_channel ('channel name','channel flags');
  $chat->unhide('channel name', 'user name', 'flags');
  $chat->hide('channel name','user name');
  $chat->close_channel('channel name');
  $chat->logoff('user name');

=head2 DESCRIPTION

C<ChatBOt::Chat> это класс, предназначеный для создания полного образа чата. Для этого он создает два списка: L<список пользователей в чате|"item_список_пользователей_в_чате"> и L<список каналов чата|"item_списко_каналов_чата">. Для его работы необходимо, что бы были установлены следующие модули:
    L<ChatBot::Chat::User|"ChatBot::Chat::User"> - объект, отвечающий за пользователя, пришедшего в чат.
    L<ChatBot::Chat::Channel|"ChatBot::Chat::Channel"> - объект, отвечающий за созданный канал в чате.
Более подробно о этих модулях читайте в прилагающемся к ним описании.

Существует следующая договоренность: 

=head3 Пользователь

Пользователь - это некто, кто прошел процедуру авторизации и зашел в чат. После входа в чат создается его "образ", который содержит "имя пользователя", "ip адрес" и, если пользователь зашел на канал, его "флаги". 
За конкретным пользователем не закреплены никакие условия, определяющие его статус на том или ином канале.

=over 4

=item имя пользователя 

Имя определяется при создании экземпляра класса Chat::User и не может быть изменено на всем протяжении жизни этого экземпляра.

=item ip пользователя

Известный чату ip-адрес зашедшего пользователя. Адрес уточняется после создания объекта L<пользователь|"пользователь"> и может изменятся на протяжении жизни "пользователя".

=item флаги пользователя

Флаги пользователя на конкретном канале. На разных каналах флаги могут быть различными, а может и не быть их вовсе (в таком случае принимается значение undef). На пример на одном канале пользователь может быть оператором, на другом - не только не оператор, но и лишенным голоса. Таким образом, флаги могут изменятся на протяжении жизни "пользователя".

=item список пользователей в чате

Этот список содержит объекты всех пользователей, которые прошли систему авторизации и зарегистрированны данным модулем.

=back

=head3 Канал

При создании канала создается его "образ", который содержит в себе: "название канала", "флаги канала", "список пользователей на канале".

=over 4

=item название канала

название конкретного канала чата.

=item флаги канала

Соотвественно, флаги конкретного канала.

=item список пользователей на канале

Канал содержит список пользователей, которые находятся на канале в данный момент.  Фактически, он содержит не просто список пользователей, а ссылки на объект пользователя, что позволяет узнать (но не изменить!) все данные о конкретном пользователе.

=item список каналов чата

Этот список содержит ссылки на все зарегистрированные в текущий момнет каналы. 

=back

=head2 CONSTRUCTOR

=over 4

=item new 

Create new object C<ChatBot::Chat>.

=back

=cut

sub new {
 	my $class = shift;
	my $self = {
		USERS => {},
		CHANNELS => {}
	};
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

 sub _init {#abstract method
	return;
 }

=head2 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 4

=item login (L<имя пользователя|"item_имя_пользователя">[, L<ip-адрес пользователя|"item_ip_пользователя">])

Создает объект "пользователь" и уточняет его ip-адрес, если он задан. После создания объект сохраняется в списке зарегистрированных пользователей.

=cut

 sub login {
	my ($self, $name, $ip) = @_;
	my $user = ChatBot::Chat::User -> new ($name, $ip);
	$self->{USERS}->{lc($user->name)} = $user;
	return $user;
 }

=item logoff (L<имя пользователя|"item_имя_пользователя">)

Пользователь с заданым именем удаляется из списка зарегистрированных пользователей.

=cut

 sub logoff {
	my ($self, $name) = @_;
	delete $self->{USERS}->{lc($name)};
	return;
 }

=item create_channel (L<название канала|"item_название_канала">[, L<флаги канала|"item_флаги_канала"> [, L<moderator|"item_модератор(ы)"> [, L<operator|"item_оператор(ы)">]]])

Создает объект "канал", уточняет его флаги, список модераторов и операторов. Если список содержит несколько операторов и/или модераторов, то он должен передаваться как ссылка на массив. После создания "канала" он сохраняется в списке зарегистрированных каналов.

=cut

 sub create_channel {
	my ($self, $name, $flags, $moderator, $operator) = @_;
	my $channel = ChatBot::Chat::Channel -> new ($name, $flags, $moderator, $operator);
	$self->{CHANNELS}->{lc($channel->name)} = $channel;
	return $channel;
 }

=item unhide (L<название канала|"item_название_канала">, L<имя пользователя|"item_имя_пользователя">[, L<флаги пользователя|"item_флаги_пользователя">])

Сохраняет пользователя в L<списке пользователей на канале|"item_список_пользователей_на_канале">. Если ранее в системе этот пользователь небыл зарегистрированн - регистрирует его (в случае такой регистрации ip адрес пользователя не известен).

=cut

 sub unhide {
	my ($self, $channel, $name, $flags) = @_;
	my $unhide_cluser = $self->{CHANNELS}->{lc($channel)};
	my $user = $self->{USERS}->{lc($name)};
	$unhide_cluser->unhide($user, $flags);
	return;
 }

=item hide (L<название канала|"item_название_канала">,L<имя пользователя|"item_имя_пользователя"> )

Удаляет пользователя из списка пользователей на канале.

=cut

 sub hide { 	# необходимо так же добавать удаление этого канала 
 		# из личного  списка каналов пользователя
	my ($self, $channel,  $name) = @_;
	my $hide_cluser = $self->{CHANNELS}->{lc($channel)};
	$hide_cluser->hide($name); 
	return;
 }
 
=item close_channel (L<название канала|"item_название_канала">)

Удаляет объект "канал" с указаным названием.

=cut

 sub close_channel {
	my ($self, $name) = @_;
	delete $self->{CHANNELS}->{lc($name)};
	return;
 }

=item is_channel (L<название канала|"item_название_канала">)

Возвращает C<true>, если указаный канал существует, инаве возвращает C<undef>

=cut

 sub is_channel {
	my ($self, $name) = @_;
	return 'true' if (defined $self->{CHANNELS}->{lc($name)});
	return;
 }

=item is_user (L<имя пользователя|"item_имя_пользоватея">)

Возвращает C<true>, если такой пользователь зарегистрированн в системе, иначе  возвращает C<undef>.

=cut

 sub is_user {
	my ($self, $name) = @_;
	return 'true' if (defined $self->{USERS}->{lc($name)});
	return;
 }

=item _get_channel (L<название канала|"item_название_канала">)

Вовзращает ссылку на объект "канал", если таков существует.

=cut 

 sub _get_channel {
	my ($self, $channel) = @_;
	return $self->{CHANNELS}->{lc($channel)};
 }

=item _get_user (L<имя пользователя|"item_имя_пользователя">)

Возвращает ссылку на объект "пользователь", если таков существует.

=back 

=cut

 sub _get_user {
	my ($self, $user) = @_;
	return $self->{USERS}->{lc($user)};
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut

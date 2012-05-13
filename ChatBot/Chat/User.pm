package ChatBot::Chat::User;

use 5.006;
use strict;
use warnings;
our $VERSION = '0.01';

=head1 NAME

ChatBot::Chat::User - Perl extension for AWCB

=head2 SYNOPSIS

  use ChatBot::Chat::User;

  my $user = Chat::User->new;
  $user->new ('user name','user ip');

=head2 DESCRIPTION

C<ChatBot::Chat::User> - это класс, отвечающий за образ "пользователя". При создании его экземпляров уточняется имя пользователя, его ip-адрес.

=head2 CONSTRUCTOR

=over 4

=item new ( имя пользователя[, ip-адрес пользователя])

Конструктор.

=back

=cut

 sub new {
 	my $class = shift;
	my $self  = {
		NAME => undef,
		IP   => undef,
		CHANNEL => []
	};
	bless ($self, $class);
	$self->_login(@_) if @_;
	return $self;
 }

 sub _login {
 	my ($self, $name, $ip) = @_;
	$self->{NAME} = $name;
	$self->{IP}	  = $ip;
	return $self;
 }

=head2 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 8

=item name

Это метод возвращает имя пользователя.

=cut

 sub name {
 	my $self = shift;
	return $self->{NAME};
 }

=item ip

Этот метод возвращает ip-адрес пользователя. В случе, если адрес был не уточнен возвращает значение C<undef>.

=cut

 sub ip {
 	my $self = shift;
	return $self->{IP};
 }

=item _set_ip (ip-адрес пользователя)

Этот метод позволяет изменить ip-адрес пользователя.

=cut

 sub _set_ip {
	my ($self, $ip) = @_;
	$self->{IP} = $ip;
	return $self->{IP};
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut

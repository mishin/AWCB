package ChatBot::Core::Config;

use 5.006;
use strict;
use warnings;
use XML::DOM;
use Class::Struct;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Config - Perl extension for Chat-Bot

=head2 SYNOPSIS

  use ChatBot::Core::Config;

=head2 DESCRIPTION

Данный модуль предназначен для извлечения (а позже, так же добавления и сохранения) данных из файла(лов?) конфигурации каналов. Одельно хотелос бы отметить, что он возвращает данные в виде собственной структуры "конфигурация", включающей структуру "модуль". Важно помнить, что данные структуры не являются защищенными.


=head2 DEPENDENCIES

Для работы модуля необходимо, что бы в системе были установлены следующие модули:
 XML::DOM
 Class::Struct

=head2 CONSTRUCTOR

=over 4

=item new ('config file')

В момент инициализации конструктор создает связь с конфигурационным файлом, абсолютный путь до которого указан в качестве параметра. Так же, в момент инициализации создаются структуры "модуль" и "конфигурация".

=cut

 sub new {
	my $class = shift;
	my $self  = {};
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

 sub _init {
 	my ($self, $file) = @_;
	my $parser = XML::DOM::Parser -> new;
	$self->{DOC} = $parser -> parsefile ($file);

=item Структура "Модуль"

Структура модуль состоит из следующих полей:
name   - содержит имя модуля
access - содержит "уровень доступа" модуля
id     - содержит порядковый номер в очереди обработки сообщений.

=cut

	struct Module => {	# создаем структуру "Модуль"
		name	=> '$',
		access	=> '$',
		id		=> '$',
		cfg		=> '$'
	};

=item структура "Конфигурация"

Структура конфигурация состоит из следующих полей:
name       - содержит название раздела или канала
modules    - содержит ссылку на массив содержащий структуры "Модуль"
moderators - содержит ссылку на массив с именами модераторов
operators  - содержит ссылку на массив с именами операторов
flags      - содержит ссылку на массив с флагами

=back

=cut

	struct Cfg => {		# создаем структуру "Конфигурация"
		name       => '$',
		modules    => '$',
		moderators => '$',
		operators  => '$',
		flags      => '$'
	};
 	return $self;
 }
 
=head1 METHODS

All of the following methods are instance methods;
you must call them on a Chat object (for example, $chat->start).

=over 4

=item find_channel ('channel name')

Этот метод предназначен для поиска конфигурации канала в конфигурационном файле. В качестве параметра он принимает название канала. При нахождении такого конала он возвращает так называемую ветку, относящуюся к искомому каналу. В случае неудачи возвращает неопределенное значение (undef).

=cut

 sub find_channel {
	my ($self, $name) = @_;
	my $nodes = $self->{DOC}->getElementsByTagName ('channel');
	my $n = $nodes->getLength;
	for (my $i = 0; $i < $n; $i++ ) {
		my $node = $nodes->item($i);
		return $node if ($node->getAttribute('name') eq $name);
	}
	return undef;
 }

=item personal_config

Этот метод ищет в конфигурационном файле данные о том, какими модулями должены обрататываться персональные сообщения. В качестве результата возращает структуру "конфигурация" L<см. сноску|"item_сноска">.

=cut

 sub personal_config {
	my $self = shift;
	my $cfg = Cfg->new;
	$cfg->name('personal');
	my $nodes = $self->{DOC}->getElementsByTagName ('personal');
	my $channel = $nodes->item(0);
	$cfg->modules($self->_get_modules($channel));
	return $cfg;
 }

=item command_config

Этот метод ищет в конфигурационном файле данные о том, какими модулями должны обрабатываться публичные команды чата. В качестве результата возвращает структуру "конфигурация" L<см. сноску|"item_сноска">.

=cut

 sub command_config {
	my $self = shift;
	my $cfg  = Cfg->new;
	$cfg->name('command');
	my $nodes = $self->{DOC}->getElementsByTagName('command');
	my $channel = $nodes->item(0);
	$cfg->modules($self->_get_modules($channel));
	return $cfg;
 }

 sub default {
	my ($self, $name) = @_;
	my $cfg = Cfg->new;
	$cfg->name($name);
	my $nodes = $self->{DOC}->getElementsByTagName ('default');
	my $channel = $nodes->item(0);
	$cfg->modules($self->_get_modules($channel));
	return $cfg;
 }


=item channel_config ('channel name')

Этот метод предназначен для поиска установок для каналов, имеющих собственные настройки. В качестве аргуметна он принимает название канала. В случае удачиного поиска или не удачного возвращает структуру "конфигурация" с тем отличием, что заполнеными будут либо все поля, либо только лишь поле с названием канала.
 
=cut

 sub channel_config {
	my ($self, $name) = @_;
	my $cfg = Cfg->new;
	$cfg->name($name);
	if (my $channel = $self->find_channel($name)) {
		$cfg->modules($self->_get_modules($channel));
		$cfg->operators($self->_get_operators($channel));
		$cfg->moderators($self->_get_moderators($channel));
	}
	else {
		$cfg = $self->default;
		$cfg->name($name);
	}
	return $cfg;
 }

 sub _get_modules {
	my ($self, $channel) = @_;
	my @modules;
	foreach my $module (@{$channel->getElementsByTagName('module')}) {
		my $cfg = Module->new;
		$cfg->name  ($module->getAttribute('name'));
		$cfg->access($module->getAttribute('access'));
		$cfg->id    ($module->getAttribute('id'));
		$cfg->cfg	($module->getAttribute('config'));
		push @modules, $cfg;
	}
	return \@modules;
 }

 sub _get_moderators {
 	my ($self, $channel) = @_;
	my @moderators;
	foreach my $moderator (@{$channel->getElementsByTagName('moderator')}) {
		push @moderators, $moderator->getAttribute('name');
	}
	return \@moderators;
 }

 sub _get_operators {
	my ($self, $channel) = @_;
	my @operators;
	foreach my $operator (@{$channel->getElementsByTagName('operator')}) {
		push @operators, $operator->getAttribute('name');
	}
	return \@operators;
 }

1;

__END__

=item сноска 

На мой взгляд определени хотя бы одного модуля для данного раздела обязательно (пусть даже и "пустого"), так как поведение программы с отсутвующим звеном не предсказуемо.

=back

=head2 ToDo

-возможно, что необходимо будет сделать метод, для извлечение установок для каналов, которым не предусмотрены отдельные конфигурации (установки по умолчанию).

=head2 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut

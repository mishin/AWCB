package ChatBot::Core;

use 5.006;
use strict;
use warnings;
use ChatBot::Core::Queue;			# module for create queure
use ChatBot::Core::Message;			#
use ChatBot::Core::Config;			#
use ChatBot::Core::Proxy::Safe;		# Access-level module
use ChatBot::Chat;					# Chat-class
#User modules
use ChatBot::Module::MainModule;	# test module;
use ChatBot::Module::Filter;		# фильтр слов.
use ChatBot::Module::Greetings;		# приветствия.
use ChatBot::Module::Birthday;		# поздравления с др.
use ChatBot::Module::FloodControl;

#use Data::Dumper;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core - Perl extension for Chat-Bot 

=head1 SYNOPSIS

  use ChatBot::Core;

=head1 DESCRIPTION

=head2 Состав системы

ChatBot - это система получения и последующей обработки сообщений. В целом она состоит из следующих частей:

=over 2

=item L<ChatBot::Core>. 

Модуль I<Core> содержит набор основных функций, относящихся к "чату". Это "создание" и "удаление" канала, регистрирование вновь прибывшего пользователя и пр. 

=item L<ChatBot::Core::Config>

Модуль I<Config> отвечает за работу с конфиругационным файлом ядра, который ограничивается списком каналов с включеными на них модулями, списком операторов и модераторов. В описании модулей, обрабатываемых канал, хранится название, порядковый номер в очереди, уровень доступа и путь к конфигурационному файлу.

=item L<ChatBot::Core::Message>

Модуль I<Message> отвечает за работу с собщениями, в частности - это получение сообщения, оперделение типа и данных сообщения, оформление в соотвествии с требованиями, возвращение уже оформленного сообщения основной системе.

=item L<ChatBot::Core::Proxy>

Модуль I<Proxy> - это родительский модуль для упаковщиков сообщений. Суть этого модуля и всех его наследников заключается в созданиии интерфейса между системой ChatBot и пользовательскими модулями. Собственно, сам модуль Proxy должен будет описать B<все> доступные средства, предоставляемые в распоряжение разработчикоа модулей. На плечи наследников ложится конкретная реализации методов на определяемом наследником уровне доступа.

=item L<ChatBot::Core::Queue>

Модуль I<Queue> предназначен для создания и манипулирования очередью.

=item L<ChatBot::Module>

Эта часть отвечает за модули, которые должны обрабатывать поступившие сообщения.

=back

Более подробно о том, как работают перечисленых части системы можно прочесть в сопровождающей их документации. Не исключено, что в дальнейшем какие либо части будут удалены или переименованы.

=head2 Описание работы системы

=head3 Старт системы

=over 2

=item new ();

При старте системы происходит инициализация всех необходимых модулей, сохранение ссылок на "пользовательские" модули в массив.  

=cut

 sub new {
	my $class = shift;
	my $self  = {};
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

=pod

в частности создается массив ссылок на инициализированные модули обрабатывающие сообщения.
Example:

=cut
	sub _init {
	my ($self, $data) = @_;

	my @modules = ( 					# сохраняем все используемые модули,
		"ChatBot::Module::MainModule",	# обрабатывающие сообщения
		"ChatBot::Module::Filter",
		"ChatBot::Module::Greetings",
		"ChatBot::Module::Birthday",
		"ChatBot::Module::FloodControl"
		);
	foreach my $module (@modules) { # создаем массив ссылок на 
									# инициализированные объекты
		my $ref = $module ->new;
		$self->{MODULE}->{lc($ref->name)} = $ref;
		printf "инициализируем модуль %s\n", $module;
	};
	my @access = ( # создаем массив "упаковщиков" сообщений.
		"ChatBot::Core::Proxy::Safe"#,
		);
	foreach my $access (@access) {  # после чего инициализируем эти
									# упаковщики
		my $ref = $access->new;
		$self->{ACCESS}->{lc($ref->access)} = $ref;
		printf "загружаем упаковщик %s\n", $access;
	}
	
	$self->{CONFIG}	= ChatBot::Core::Config ->new ($data->{config});
	$self->{QUEUE}	= ChatBot::Core::Queue  ->new;
	$self->{CHAT}	= ChatBot::Chat->new;


	# создаем "очередь" модулей, обрабатывающих "персональные сообщения"
	my $personal  = $self->{CONFIG}->personal_config; #get config structure
	my $queue = $self->create_queue($personal);
	$self->{PERSONAL} = $queue;

	# создаем "очередь" модулей, обрабатывающих "команды чата"
	my $command  = $self->{CONFIG}->command_config; #get config structure
	$queue = $self->create_queue($command);
	$self->{COMMAND} = $queue;

	$self->{MESSAGE}= ChatBot::Core::Message->new($data);

	#Create channel
	# temporarry
	$self->create_channel($data->{channel});
 return;
 }

=head3 Цикл системы

Для обеспечения работы системы существуют следующие методы:

=over 2

=item create_queue ('config')

Этот метод предназначен для создания очереди. В качестве параметра он получает структуру "конфигурация", определение полей которой описано в документации к модулю Config. После того, как метод выполнил свою работу он возвращает ссылку на объект "очередь".

=cut 

 sub create_queue {
	my ($self, $cfg) = @_;
	my %queue;
	my $modules = $cfg->modules;
	return unless $modules;
	foreach my $cfg (@$modules) {
		my $module = $self->{MODULE}->{lc($cfg->name)}->new($cfg->access, $cfg->cfg);
		$queue{$cfg->id} = $module;
	}
	my $queue = $self->{QUEUE}->new(\%queue);
	return $queue;
 }

=item get_new_message

Данный метод предназначен для получения нового сообщения. Он использует функцию get_new_message модуля Message. После получения сообщения и определения его пригодности оно передается для дальнейшей обработки одному из соответвующих методов. Все эти методы (personal, command и channel) определены ниже . После того, как сообщение было обработано - возвращает один из следующих ответов:

=over 2

=item close 

если было получено последнее сообщение для системы

=item true  

если было получено сообщение метод работы с которым был описан системе

=item false 

если было получено сообщение, которое не предусмотрено для обработки системой.

=back

=cut

 sub get_new_message {
	my $self = shift;
	my $message = $self->{MESSAGE}->get_new_message;
	return 'close' unless defined $message;
	$self->cycle($message) unless ($message eq 'false');
	return $message;
 }

=item cycle ($queue, $message);

Этот метод предназначен для обеспечения обработки нового сообщения в порядке определенной для него очереди. Для его работы небходимо, что бы он получил объект "очередь" и "сообщение". На основе данных, хранящихся в "очереди" он начинает следущий цикк, который продолжается до тех пор, пока не получен последний элемент очереди. Цикл следующий: 
 Получаем модуль, уровень его доступа, объект "канал" к которому относится данное сообщение. После того, как были получены необходимые данные "сообщение" и "канал" пакуются в "упаковщик" соответствующий уровню доступа текущего модуля. После чего модуль получает упакованные данные и может приступать к их обработке.
Данные, которые пакуются зависят от самого паковщика. Так, на пример, для модулей, обрабатывающих сообщения персонального канала объект канал как таковой не нужен вообще.

=back

=cut

 sub cycle {
	my ($self, $message) = @_;
	my $queue = $self->{CHANNEL}->{lc($message->channel)};
	for ($queue->first; $queue->is_done; $queue->next) {
		my $module = $queue->get_current;
		my $access = $module->access;
		my $channel = $self->{CHAT}->_get_channel($message->channel);
		my $ref = $self->{ACCESS}->{$access}->new($message, $channel);# $channel may be not defined
		my $res = $module->go($ref);
		$self->{MESSAGE}->send_new_message($message->channel, $res) if (defined $res);
	}
	return;
 }

 sub create_channel {
	my ($self, $name) = @_;
	my $config  = $self->{CONFIG}->channel_config($name); #get config structure
	my $queue   = $self->create_queue($config); #create queue for this channel
	$self->{CHAT}->create_channel($name, $config->flags, $config->moderators, $config->operators); #create channel
	$self->{CHANNEL}->{lc($name)} = $queue; #save queue for this channel
	return $self;
 }

1;
__END__

=head3 Работа цикла.

Соответвенно, логика работы такова:

=over 2

=item 1

Получаем сообщение

=item 2

Определяем его тип и передаем соотвествующему методу

=item 3

В методе указано, как определить очередь для данного типа сообщения, что и делам.

=item 4

Обрабатываем сообщение в порядке очереди. После чего возвращаемся к п.1.

=back

=back 

=head1 AUTHOR

Novgorodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=head1 SEE ALSO

L<ChatBot::Core::Config>, L<ChatBot::Core::Message>, L<ChatBot::Core::Queue>, L<ChatBot::Core::Proxy>

=cut

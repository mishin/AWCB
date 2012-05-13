#!/usr/bin/perl
#
#
use strict;
use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;

use ChatBot;

print <<INTRO;

A.W.C.B. (Another Web Chat Bot)
Copyright (C) 2005, Cyrill Novgorodcev, <cynovg\@gmail.com>

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

INTRO

my (%data, $man, $help, $ctrl_c);
$SIG{INT} = sub {$ctrl_c++};
$data{channel} = 'awcb-test';
$data{config}  = "exampl.config";

GetOptions ('username=s'=>\$data{name},
			'password=s'=>\$data{passwd},
			'channel=s'	=>\$data{channel},
			'config=s'	=>\$data{config},
			'proxy=s'	=>\$data{proxy},
			'help|?'	=>\$help,
			'man'		=>\$man
			) or pod2usage(2);
pod2usage(1) if  $help;
pod2usage(-exitstaus=>0, -verbose=>2) if $man;
pod2usage(2) unless $data{name};

get_passwd() unless $data{passwd};

my $chat = ChatBot->new(\%data);
while (not $ctrl_c) {
	last if ($chat->get_new_message eq 'close');
}
$chat->logout;

sub get_passwd {
	eval {
		local $SIG{ALRM} = sub { die "timeout"};
		alarm (60*5);
		eval {
			ReadMode 'noecho';
			for (my $count = 0; not $data{passwd} || $count >= 3; $count++ ) {
				print "Enter password: ";
				$data{passwd} = ReadLine 0;
				chomp $data{passwd};
				print "\n";
			}
		};
		alarm 0;
	};
	alarm 0;
	ReadMode 'normal';
	print "\n";
	exit if $@ && $@ !~/timeout/;
	exit unless $data{passwd};
}

__END__

=encoding utf-8
=head1 NAME

AWCB - Another Web-Chat Bot

=head1 SYNOPSIS

start.pl --username=NICK [options...]

 Options:
 --username=NICK     имя пользователя;
 --password=PASSWORD пароль пользователя;
 --channel=CHANNEL   название канала;
 --proxy=ADDR:PORT   адрес и порт прокси сервера;
 --config=FILE       конфиг.файл и путь к нему;
 --help              этот текст;
 --man               детальное описание программы.

=head1 DESCRIPTION

Данная версия AWCB адаптирована для сервиса L<http://chat.chat.ru/>. Так как это даже не демонстрационная версия, требовать от нее можно не многого. В данный момент с помощь программы можно зайти на произвольный канал и полученые сообщения будут отбрабатываться модулями в соотвествии с настройками, указаными в конфигурации.

Теоретически, уже возможно написать собственные модули, но насколько изменится предоставляемый модулям интерфейс - еще не знаю. Более детальная информация о написании собственных модулей и/или участии в проекте расположена на домашней страничке. 

Так как парсер расчитан на стиль "текст" (или 9-й), то этот стиль уже должен быть указан в настройках пользователя в чате. Парсеры для других стилей не планируются, по крайней мере - пока. Более детально описание настроек смотрите в файле README.

Что ожидается от системы Вы можете узнать посетив домашнюю страницу проекта.

Домашнаяя страничка находится по адресу:

L<http://skomopox.skipitnow.org/AWCB/> 

Самая свежая версия программы всегда доступна по адресу L<http://sourceforge.net/projects/awcb/>. Там же расположена cvs-версия.

=head1 OPTIONS DETAIL

=over 4

=item B<--username=NICK>

Используется в качестве имени пользователя, под которым программа входит в систему

=item B<--password=PASSWORD>

Используется в качестве пароля для указаного имени пользователя. В случае, если этот параметр не указан в качестве параметра пароль будет запрошен повторно
и есть повторно пропустить его, то программа автоматически завершится.

=item B<--channel=CHANNEL NAME>

Канал, на которых программа зайдет сразу после старта системы. Если название канала содержит символ пробела,то название канала необходимо написать в кавычках. В данный момент если не введено название файла, то программа по умолчанию заходит на канал awcb-test.

=item B<--proxy=ADDR:PORT>

Если используется прокси-сервер, то в этом параметре надо указать его адрес и порт разделенные двоеточием

=item B<--config=FILE>

Имя конфигурационного фала и, если файл находится не в текущей директории, путь к нему.

=item B<--help>

Выводит текст помощи и выходит из программы.

=item B<--man>

Выводит текст описание программы и выходит.

=back

=head1 AUTHOR INFORMATION

Copyright (C) 2005, Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

This protgram is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=head1 BUGS

В данный момент мне известно, что если в короткий промежуток времени перезапускать программу под одним и тем же ником, то она может некоторое время не отправлять сообщения в чат. Это связано с тем, что каждое сообщение имее порядоквый номер и если отправлять сообщения с меньшим номером нежели уже полученое (а именно это происходит при рестарте, сбрасывается счетчик сообщений), то сервис (чат) сообщение игнорирует.

Похоже, что программа на дух не переносит персональные сообщения.

=cut

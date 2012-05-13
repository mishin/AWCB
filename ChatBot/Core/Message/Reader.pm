package ChatBot::Core::Message::Reader;

use 5.006;
use strict;
use warnings;
use Net::HTTP;

#use Data::Dumper;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Message::Reader::ChatRuReader - Perl extension for ChatBot 

=head1 SYNOPSIS

  use ChatBot::Core::Message::Reader::ChatRuReader;

=head1 DESCRIPTION


=cut

 sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self  = {};
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

 sub _init {
 	my ($self, $data) = @_;
	printf "Захожу на канал %s под ником %s\n", $data->{channel}, $data->{name};
	printf "Используя проски %s порт %s\n", split /:/,$data->{proxy} if
		(defined $data->{proxy});
	$self->{NAME} = $data->{name};
	$self->{PSWD} = $data->{passwd};
	$self->{CHNL} = $data->{channel};
	my ($host, $get);
	if (defined $data->{proxy}) {
		$host = $data->{proxy};
		$get  = sprintf 
			"http://chat.chat.ru/pframe?username=%s&passwd=%s&channel=%s", 
					$data->{name},$data->{passwd},$data->{channel};
	}
	else {
		$host = "chat.chat.ru";
		$get  = sprintf "/pframe?username=%s&passwd=%s&channel=%s", 
					$data->{name},$data->{passwd},$data->{channel};
	}
	die \&say_error($@) unless 
		my $s = Net::HTTP->new(Host => $host);
	$s->write_request(GET => $get,'User-Agent' => "Mozilla/5.0");
	my($code, $mess, %h) = $s->read_response_headers;
	$self->{SOCKET} = $s;
	$self->{CODE}   = $code;
	$self->{MESS}   = $mess;
	return;
 }

 sub read_message {
 	my $self = shift;
	my $buf;
	my $channel = $self->{CHNL};
	# Возможно, что из-за задержек сети приходит сразу больше чем одно
	# сообщение. По этоу необходимо проверять, сколько действительно
	# было получено сообщений и если больше чем одно, то сохранять 
	# "лишние" в временном буфере. Следовательно, так как в буфере 
	# могу находится необработаные сообщения его следует проверять 
	# в первую очередь. Если извлечение из буфера оказалось неудачным
	# (буфер пуст), то пробуем получить сообщение с канала.
	$buf = shift @{$self->{BUFF}->{lc($channel)}};
	unless ($buf) { 
		my $n = $self->{SOCKET}->read_entity_body($buf, 1024);
		return "read failed: $!" unless defined $n;
		return undef unless $n;
		my @lines = split/\n/, $buf;
		if (@lines >=2) {
			$buf = shift @lines;
			push @{$self->{BUFF}->{lc($channel)}}, @lines;
		}
	}
	return "\'$channel\' $buf";
 }

 sub say_error {
	my $message = shift;
	$message =~ s/^(.*)\sat\s.*$/$1/;
	die "Проверьте соединение\n$message\n";
 }


1;
__END__

=head1 AUTHOR

Novogrodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=cut
